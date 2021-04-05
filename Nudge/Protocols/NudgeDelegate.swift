//
//  AddReminderDelegate.swift
//  Nudges
//
//  Created by Benny Pham on 1/9/21.
//

import Foundation

protocol NudgeDelegate {
    func addReminder(_ nudge: Nudge)
    func editReminder(_ nudge: Nudge)
}
