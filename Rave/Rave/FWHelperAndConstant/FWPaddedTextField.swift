//
//  FWPaddedTextField.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 23/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

class FWPaddedTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
    }
}

private var maxLengths = [UITextField: Int]()

extension FWPaddedTextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return Int.max
            }
            return length
        }
        
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(limitLength(_:)), for: .editingChanged)
        }
    }
    
    func limitLength(_ textField: UITextField) {
        guard let prospectiveText = textField.text
            , prospectiveText.characters.count > maxLength else {
                return
        }
        
        let selection = selectedTextRange
        text = prospectiveText.substring(with: Range(prospectiveText.startIndex ..< prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)))
        selectedTextRange = selection
    }
}
