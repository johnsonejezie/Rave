//
//  Helper.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 09/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import Foundation
import UIKit

internal struct FWHelpers {
    
    internal static func getCodeForBank(_ name:String)-> String? {
        if FWConstants.banks.isEmpty {
            getListOfBanks()
        }
        for bank in FWConstants.banks {
            if bank.name == name {
                return bank.code
            }
        }
        return nil
    }
    
    internal static func getListOfBanks() {
        let resource = bankListResource()
        FWRequest().load(resource: resource, completion: { result in
            guard let result = result else { return }
            FWConstants.banks = result.flatMap{Bank.init(json: $0)}
            FWConstants.listOfBankNames = FWConstants.banks.map{$0.name}
            FWConstants.listOfBankNames.insert("SELECT BANK", at: 0)
        })
    }
    
    private static func bankListResource()->Resource<[JSONDictionary]> {
        let endpoint = FWConstants.BaseURL + "banks"
        let url = URL(string:endpoint)!
        return Resource(url: url, parseJSON: { result in
            guard let result = result as? [String:Any] else { return nil }
            if let json = result["data"] as? [JSONDictionary] {
                return json
            }
            return nil
        })
    }
    
    internal static func currentFormmatter (_ amount:Float)->String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.alwaysShowsDecimalSeparator = true
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: NSNumber(value: Float(amount) as Float))!
    }
    
    internal static func getIP(completion:@escaping (String?)->Swift.Void) {
        if let url = URL(string: FWConstants.Ipify) {
            self.getData(url: url, completion: { (data) in
                guard let data = data else {
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let json = json as? [String:String] {
                    completion(json["ip"])
                }
            })
        }
    }
    
    internal static func jsonStringify(_ jsonObject:[String:Any], prettyPrinted: Bool = false)-> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(jsonObject)
        {
            do
            {
                let data = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                {
                    return string as String
                }
            }
            catch
            {
            }
        }
        return ""
    }
    
    fileprivate static func getData(url:URL, completion: @escaping (Data?) -> Swift.Void ) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
            completion(data)
        }).resume()
        
    }
    
    fileprivate static func MD5(string: String) -> Data? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    internal static func getEncryptionKey(_ secretKey:String)->String {
        let md5Data = FWHelpers.MD5(string:secretKey)
        let md5Hex =  md5Data!.map { String(format: "%02hhx", $0) }.joined()
        
        var secretKeyHex = ""
        
        if secretKey.contains("FLWSECK-") {
            secretKeyHex = secretKey.replacingOccurrences(of: "FLWSECK-", with: "")
        }
        if secretKey.contains("-X") {
            secretKeyHex = secretKeyHex.replacingOccurrences(of: "-X", with: "")
        }

        let index = secretKeyHex.index(secretKeyHex.startIndex, offsetBy: 12)
        let first12 = secretKeyHex.substring(to: index)
        
        let last12 = md5Hex.substring(from:md5Hex.index(md5Hex.endIndex, offsetBy: -12))
        return first12 + last12        
        
    }
}
