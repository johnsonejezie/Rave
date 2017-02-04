//
//  ViewController.swift
//  Rave
//
//  Created by Johnson Ejezie on 29/01/2017.
//  Copyright © 2017 johnsonejezie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var ravePaymentManager:RavePaymentManager?
    
    let publicKey = "FLWPUBK-4f031f19877151a985dfc699ca1389b8-X"
    let secretKey = "FLWSECK-fbbf7e29fe4ab5c9ad3316abf428712f-X"
    var txRef = "rave-checkout-1485001802"
    
    //NO Auth
    let noauthKey = "FLWPUBK-33095a9d243a3469a1290bead88c9c66-X"
    let noauthSecret = "FLWSECK-79233b20f51ddb465a0cd809cd93cbfc-X"
    
    // Random Debit
    let randomDebitKey = "FLWPUBK-1265f3ea4b8272a3e4bccd8c73bfb6ea-X"
    let randomDebitSecret = "FLWSECK-ec14978c0ce1cdf2becf143f21029e62-X"
    
    // Pin
    let pinKey = "FLWPUBK-f237f3638839a8380c1453a4df834a56-X"
    let pinSecret = "FLWSECK-1abb44c87c80464e12a650154984ee65-X"
    
    @IBAction func onPayButtonTapped(_ sender: Any) {
        ravePaymentManager = RavePaymentManager(publicKey, secretKey: secretKey, appName: "Demo", transactionDescription: "Payment for items...", amount: 100, email: "johnsonejezie@gmail.com", txRef: txRef)
        ravePaymentManager?.country = "Nigeria"
        ravePaymentManager?.logoImage = UIImage(named: "logo.jpg")
        ravePaymentManager?.delegate = self
        ravePaymentManager?.show()
    }
    
}

extension ViewController:RavePaymentManagerDelegate {
    
    func ravePaymentManagerDidCancel(_ ravePaymentManager: RavePaymentManager) {
        print("cancel")
    }
    
    func ravePaymentManager(_ ravePaymentManager: RavePaymentManager, didCompletePaymentWithResult result: RavePaymentResult) {
        print(result.status)
        print(result.message)
    }
}

