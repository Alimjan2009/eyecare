//
//  ICTextField.swift
//  eye
//
//  Created by Alimjan on 2021/3/18.
//

import Cocoa
class ICTextField: NSTextField {
    override func textDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ICTextFieldDidChange"), object: self)
        
        super.textDidChange(notification)
    }
}
