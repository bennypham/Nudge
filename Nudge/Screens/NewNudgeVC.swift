//
//  NewNudgeVC.swift
//  Nudges
//
//  Created by Benny Pham on 11/11/20.
//

import UIKit
import RealmSwift

class NewNudgeVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    let inset = CGFloat(10)
    var delegate: NudgeDelegate?
    var nudge: Nudge!
    
    var titleField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Title"
        textField.layer.cornerRadius = 15
        textField.backgroundColor = .systemBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    let bodyField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Description"
        textField.layer.cornerRadius = 15
        textField.backgroundColor = .systemBackground
        textField.resignFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleField.delegate = self
        bodyField.delegate = self
        configureNavigationBar()
        configureTitleField()
        configureBodyField()
        configureDatePicker()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    private func configureNavigationBar() {
        if let nudge = nudge {
            navigationItem.title = "Edit \(nudge.title)"
            fillTextFields()
        } else {
            navigationItem.title = "Add New Nudge"
        }
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
    }
    
    
    private func fillTextFields() {
        titleField.text = nudge.title
        bodyField.text = nudge.body
        datePicker.date = nudge.date
    }
    
    
    private func updateNudge() {
        let realm = try! Realm()
        do {
            try realm.write {
                let updatedNudge = nudge
                updatedNudge!.title = titleField.text!
                updatedNudge!.body = bodyField.text!
                updatedNudge!.date = datePicker.date
                nudge = updatedNudge
            }
        } catch {
            print("Error in updating nudge")
        }
        delegate?.editNudge(nudge: nudge)
    }
    
    
    private func validateFields() -> Bool {
        if titleField.text!.isEmpty || bodyField.text!.isEmpty {
            let newAlertController = UIAlertController(title: "Empty Fields", message: "All fields must be filled", preferredStyle: .alert)

            let alertAction = UIAlertAction(title: "OK", style: .destructive) { (alert) in
                newAlertController.dismiss(animated: true)
            }

            newAlertController.addAction(alertAction)
            present(newAlertController, animated: true)
            return false
        } else {
            return true
        }
    }
    
    
    private func addNewNudge() {
        let realm = try! Realm()
        
        let newNudge = Nudge()
        do {
            try realm.write {
                newNudge.title = titleField.text!
                newNudge.body = bodyField.text!
                newNudge.date = datePicker.date
                realm.add(newNudge)
                nudge = newNudge
            }
        } catch {
            print("Error trying to update")
        }
        delegate?.addNudge(nudge: newNudge)
    }
    
    
    // MARK: - Selectors
    @objc func handleSave() {
        
        if validateFields() {
            if nudge != nil {
                updateNudge()
            } else {
                addNewNudge()
            }
        }
    }
    
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension

extension NewNudgeVC {
    
    
    private func configureTitleField() {
        view.addSubview(titleField)
        titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset).isActive = true
        titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
        titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        titleField.becomeFirstResponder()
    }
    
    
    private func configureBodyField() {
        view.addSubview(bodyField)
        bodyField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20).isActive = true
        bodyField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
        bodyField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
        bodyField.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    
    private func configureDatePicker() {
        view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: bodyField.bottomAnchor, constant: 40).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
