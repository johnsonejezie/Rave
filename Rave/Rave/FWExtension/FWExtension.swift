//
//  FWExtension.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 08/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

internal extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    func containsOnlyDigits() -> Bool
    {
        
        let notDigits = NSCharacterSet.decimalDigits.inverted
        
        if rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
        {
            return true
        }
        
        return false
    }
}

internal extension UIWindow {
    
    static func visibleWindow() -> UIWindow? {
        var currentWindow = UIApplication.shared.keyWindow
        
        if currentWindow == nil {
            let frontToBackWindows = Array(UIApplication.shared.windows.reversed())
            
            for window in frontToBackWindows {
                if window.windowLevel == UIWindowLevelNormal {
                    currentWindow = window
                    break
                }
            }
        }
        
        return currentWindow
    }
    
}
