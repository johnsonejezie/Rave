//
//  CreditCardFormatter.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 23/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

var creditCardFormatter : CreditCardFormatter
{
    return CreditCardFormatter.sharedInstance
}

internal class CreditCardFormatter : NSObject
{
    static let sharedInstance : CreditCardFormatter = CreditCardFormatter()
    
    internal func formatToCreditCardNumber(textField : UITextField, withPreviousTextContent previousTextContent : String?, andPreviousCursorPosition previousCursorSelection : UITextRange?) {
        var selectedRangeStart = textField.endOfDocument
        if textField.selectedTextRange?.start != nil {
            selectedRangeStart = (textField.selectedTextRange?.start)!
        }
        if  let textFieldText = textField.text
        {
            var targetCursorPosition : UInt = UInt(textField.offset(from:textField.beginningOfDocument, to: selectedRangeStart))
            let cardNumberWithoutSpaces : String = removeNonDigitsFromString(string: textFieldText, andPreserveCursorPosition: &targetCursorPosition)
            if cardNumberWithoutSpaces.characters.count > 19
            {
                textField.text = previousTextContent
                textField.selectedTextRange = previousCursorSelection
                return
            }
            
            var cardNumberWithSpaces = ""
            
            cardNumberWithSpaces = insertSpacesIntoEvery4DigitsIntoString(string: cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
            textField.text = cardNumberWithSpaces
            if let finalCursorPosition = textField.position(from:textField.beginningOfDocument, offset: Int(targetCursorPosition))
            {
                textField.selectedTextRange = textField.textRange(from: finalCursorPosition, to: finalCursorPosition)
            }
        }
    }
    
    private func removeNonDigitsFromString(string : String, andPreserveCursorPosition cursorPosition : inout UInt) -> String {
        var digitsOnlyString : String = ""
        for index in stride(from: 0, to: string.characters.count, by: 1)
        {
            let charToAdd : Character = Array(string.characters)[index]
            if isDigit(character: charToAdd)
            {
                digitsOnlyString.append(charToAdd)
            }
            else
            {
                if index < Int(cursorPosition)
                {
                    cursorPosition -= 1
                }
            }
        }
        return digitsOnlyString
    }
    
    private func isDigit(character : Character) -> Bool
    {
        return "\(character)".containsOnlyDigits()
    }
    
    private func insertSpacesIntoEvery4DigitsIntoString(string : String, andPreserveCursorPosition cursorPosition : inout UInt) -> String {
        var stringWithAddedSpaces : String = ""
        for index in stride(from: 0, to: string.characters.count, by: 1)
        {
            if index != 0 && index % 4 == 0 && index < 16
            {
                stringWithAddedSpaces += " "
                
                if index < Int(cursorPosition)
                {
                    cursorPosition += 1
                }
            }
            if index < 16 {
                let characterToAdd : Character = Array(string.characters)[index]
                stringWithAddedSpaces.append(characterToAdd)
            }
        }
        return stringWithAddedSpaces
    }
    
}
