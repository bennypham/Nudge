//
//  NudgeDelegate.swift
//  Nudges
//
//  Created by Benny Pham on 1/9/21.
//

import Foundation

protocol NudgeDelegate {
    func addNudge(nudge: Nudge)
    func editNudge(nudge: Nudge)
}
