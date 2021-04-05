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
typealias ReminderDataSource = UICollectionViewDiffableDataSource<NudgesListVC.Section, Nudge>
typealias RemindersSnapshot = NSDiffableDataSourceSnapshot<NudgesListVC.Section, Nudge>


class NudgesListVC: UIViewController {
    
    enum Section {
        case main
    }
    
    // MARK: - Properties
    let realm = try! Realm()
    var nudges : Results<Nudge>!
    var notificationToken : NotificationToken?
    
    var collectionView: UICollectionView!
    var dataSource: ReminderDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nudges = realm.objects(Nudge.self).sorted(byKeyPath: "_id", ascending: true)
//        print(realm.configuration.fileURL?.path)
        
        notificationToken = realm.observe({ (notification, realm) in
            print("deleting nudge")
            self.updateData(on: self.nudges)
        })
        
//        requestNotificationPermission()
        configureNavigationController()
        configureCollectionView()
        configureDataSource()
        updateData(on: nudges)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
    }
    
    // MARK: - Functions
    
    
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
//            success, error in
//
//            if success {
//                print("Schedule Notification")
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        })
//    }
    
    
    private func configureNavigationController() {
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addNewReminder))
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
            let realm = try! Realm()
            let tmpNudge = realm.objects(Nudge.self).filter("_id == '\(nudge._id)'")
            do {
                try self.realm.write{
                    self.realm.delete(tmpNudge)
                }
            } catch {
                print("Error trying to delete")
            }

            
//            var snapshot = self.dataSource.snapshot()
//            snapshot.deleteItems([nudge])
//            self.dataSource.apply(snapshot, animatingDifferences: true)


            let reminders = self.realm.objects(Nudge.self)
            self.updateData(on: reminders)

            completion(true)
        }


        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    private func configureDataSource() {
        let cellRegistration = UICollectionViewCellRegistration{ (cell: UICollectionViewListCell, _, nudge: Nudge) in
            var content = cell.defaultContentConfiguration()
            content.text = nudge.title
            content.secondaryText = nudge.body
            cell.accessories = [.disclosureIndicator()]
            cell.contentConfiguration = content
        }
        
        dataSource = ReminderDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, nudge) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: nudge)
            return cell
        })
    }
    
    
    func updateData(on nudges: Results<Nudge>) {
        var snapshot = RemindersSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(nudges))
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
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
                print("There was an error scheduling a reminder")
            }
        })
    }

    
    // MARK: - Selectors
    @objc func addNewReminder() {
        let newRemindersVC = NewNudgeVC()
        newRemindersVC.delegate = self
        
        navigationController?.present(UINavigationController(rootViewController: newRemindersVC), animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate

extension NudgesListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let reminder = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        let editReminderVC = NewNudgeVC()
        editReminderVC.delegate = self
        editReminderVC.nudge = reminder
        
        navigationController?.present(UINavigationController(rootViewController: editReminderVC), animated: true)
    }
}

// MARK: - ReminderDelegate

extension NudgesListVC: NudgeDelegate {
    
    
    // Add reminder delegate function
    func addReminder(_ nudge: Nudge) {
        self.dismiss(animated: true) {
    
            // snapshot for new reminder
            self.updateData(on: self.nudges)
            
            // schedule push notification for reminder
//            self.schedulePushNotification(with: reminder)
        }
    }
    
    
    // Edit reminder delegate function
    func editReminder(_ nudge: Nudge) {
        self.dismiss(animated: true) {
            
            self.updateData(on: self.nudges)


            // schedule push notification for reminder
//            self.schedulePushNotification(with: reminder)
        }
    }
}

extension Results {
    func toArray() -> [Element] {
        return compactMap {
            $0
        }
    }
}
