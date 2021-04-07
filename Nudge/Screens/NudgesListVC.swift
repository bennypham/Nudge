//
//  NudgesListVC.swift
//  Nudges
//
//  Created by Benny Pham on 11/5/20.
//

import UIKit
import UserNotifications
import RealmSwift


typealias UICollectionViewCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Nudge>
typealias NudgeDataSource = UICollectionViewDiffableDataSource<NudgesListVC.Section, Nudge>
typealias NudgeSnapshot = NSDiffableDataSourceSnapshot<NudgesListVC.Section, Nudge>


class NudgesListVC: UIViewController {
    
    enum Section {
        case main
    }
    
    // MARK: - Properties
    let realm = try! Realm()
    var nudges : Results<Nudge>!
    var notificationToken : NotificationToken?
    
    var collectionView: UICollectionView!
    var dataSource: NudgeDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nudges = realm.objects(Nudge.self).sorted(byKeyPath: "_id", ascending: true)
//        print(realm.configuration.fileURL?.path)
        
        notificationToken = realm.observe({ (notification, realm) in
            print("Notification Realm Observe")
            self.configureDataSource()
        })
        
        requestNotificationPermission()
        configureNavigationController()
        configureCollectionView()
        configureDataSource()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }
    
    
    // MARK: - Functions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            success, error in

            if success {
                print("Schedule Notification")
            } else if let error = error {
                print("Error: \(error)")
            }
        })
    }
    
    
    private func configureNavigationController() {
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewNudge))
    }
    
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createOneColoumnFlowLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    
    private func createOneColoumnFlowLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        listConfiguration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }
            guard let nudge = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            print(nudge)
            return self.trailingSwipeActionsConfigurationProvider(nudge)
        }
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    
    func trailingSwipeActionsConfigurationProvider(_ nudge: Nudge) -> UISwipeActionsConfiguration {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            do {
                try self.realm.write{
                    self.realm.delete(nudge)
                }
            } catch {
                print("Error trying to delete")
            }

            completion(true)
        }


        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    private func configureDataSource() {
        let cellRegistration = UICollectionViewCellRegistration{ (cell: UICollectionViewListCell, indexPath, nudge: Nudge) in
            var content = UIListContentConfiguration.subtitleCell()
            content.text = nudge.title
            content.secondaryText = nudge.body
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = NudgeDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, nudge) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: nudge)
        })
        
        var snapshot = NudgeSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(nudges))
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    
    func schedulePushNotification(with nudge: Nudge) {
        let content = UNMutableNotificationContent()
        content.title = nudge.title
        content.body = nudge.body
        content.sound = .default

        let pickedDate = nudge.date
        let triggerNotification = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: pickedDate), repeats: false)

        let requestNotification = UNNotificationRequest(identifier: nudge._id.stringValue, content: content, trigger: triggerNotification)
        
        UNUserNotificationCenter.current().add(requestNotification, withCompletionHandler: { error in
            if error != nil {
                print("There was an error scheduling a nudge")
            }
        })
    }

    
    // MARK: - Selectors
    @objc func addNewNudge() {
        let newNudgesVC = NewNudgeVC()
        newNudgesVC.delegate = self
        
        navigationController?.present(UINavigationController(rootViewController: newNudgesVC), animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate
extension NudgesListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let nudge = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        let editNudgeVC = NewNudgeVC()
        editNudgeVC.delegate = self
        editNudgeVC.nudge = nudge
        
        navigationController?.present(UINavigationController(rootViewController: editNudgeVC), animated: true)
    }
}

// MARK: - NudgeDelegate
extension NudgesListVC: NudgeDelegate {
    
    
    func addNudge(nudge: Nudge) {
        self.dismiss(animated: true) {
            
            // schedule push notification for nudge
            self.schedulePushNotification(with: nudge)
        }
    }
    
    
    func editNudge(nudge: Nudge) {
        self.dismiss(animated: true) {
            
            // schedule push notification for nudge
            self.schedulePushNotification(with: nudge)
        }
    }
}
