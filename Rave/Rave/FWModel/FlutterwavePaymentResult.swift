//
//  PayResponse.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 15/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

struct RavePaymentResult {
    var status:String
    var message:String
    let data:RaveResponseData
}

struct RaveResponseData {
    var id:NSNumber = 0
    var txRef:String = ""
    var amount:Int16 = 0
    var chargeResponseCode:String = ""
    var chargeResponseMessage:String = ""
    var authModelUsed:AuthModelUsed = .VBVSECURECODE
    var flwRef = ""
    var currency:String = ""
    var IP:String = ""
    var narration:String = ""
    var status:String = ""
    var vbvrespmessage:String = ""
    var authurl:String = ""
    var vbvrespcode:String = ""
    var acctvalrespmsg:String = ""
    var acctvalrespcode:String = ""
    var createdAt:String = ""
    var paymentType:String = ""
    var chargeToken:ChargeToken?
}

extension RaveResponseData {
    init?(json:JSONDictionary) {
        if let id = json["id"] as? NSNumber {
            self.id = id
        }
        if let txRef = json["txRef"] as? String {
            self.txRef = txRef
        }
        if let amount = json["amount"] as? Int16 {
            self.amount = amount
        }
        if let chargeResponseCode = json["chargeResponseCode"] as? String {
            self.chargeResponseCode = chargeResponseCode
        }
        if let flwRef = json["flwRef"] as? String {
            self.flwRef = flwRef
        }
        if let chargeResponseMessage = json["chargeResponseMessage"] as? String {
            self.chargeResponseMessage = chargeResponseMessage
        }
        if let authModelUsed = json["authModelUsed"] as? String {
            self.authModelUsed = AuthModelUsed.build(rawValue: authModelUsed)
        }
        if let currency = json["currency"] as? String {
            self.currency = currency
        }
        if let IP = json["IP"] as? String {
            self.IP = IP
        }
        if let narration = json["narration"] as? String {
            self.narration = narration
        }
        if let status = json["status"] as? String {
            self.status = status
        }
        if let vbvrespmessage = json["vbvrespmessage"] as? String {
            self.vbvrespmessage = vbvrespmessage
        }
        if let authurl = json["authurl"] as? String {
            self.authurl = authurl
        }
        if let vbvrespcode = json["vbvrespcode"] as? String {
            self.vbvrespcode = vbvrespcode
        }
        if let acctvalrespmsg = json["acctvalrespmsg"] as? String {
            self.acctvalrespmsg = acctvalrespmsg
        }
        if let acctvalrespcode = json["acctvalrespcode"] as? String {
            self.acctvalrespcode = acctvalrespcode
        }
        if let createdAt = json["createdAt"] as? String {
            self.createdAt = createdAt
        }
        if let paymentType = json["paymentType"] as? String {
            self.paymentType = paymentType
        }
        if let chargeToken = json["chargeToken"] as? JSONDictionary {
            self.chargeToken = ChargeToken(json: chargeToken)
        }
    }
}

enum AuthModelUsed:String {
    case VBVSECURECODE = "VBVSECURECODE"
    case NOAUTH = "NOAUTH"
    case RANDOMDEBIT = "RANDOM_DEBIT"
    case PIN = "PIN"
    
    static func build(rawValue:String) -> AuthModelUsed {
        return AuthModelUsed(rawValue: rawValue) ?? .VBVSECURECODE
    }
}

struct ChargeToken {
    var shortcode:String = ""
    var embedToken:String = ""
}

extension ChargeToken {
    init?(json:JSONDictionary) {
        if let shortcode = json["user_token"] as? String {
            self.shortcode = shortcode
        }
        if let embedToken = json["embed_token"] as? String {
            self.embedToken = embedToken
        }
    }
}

struct Bank {
    var code:String = ""
    var name:String = ""
    
}

extension Bank {
    init?(json:JSONDictionary) {
        if let code = json["code"] as? String {
            self.code = code
        }
        if let name = json["name"] as? String {
            self.name = name
        }
    }
}
