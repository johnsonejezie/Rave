//
//  EnterKeyViewController.swift
//  Rave
//
//  Created by Johnson Ejezie on 28/01/2017.
//  Copyright © 2017 johnsonejezie. All rights reserved.
//

import UIKit

class EnterKeyViewController: UIViewController {

    @IBOutlet var desc: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var appName: UITextField!
    @IBOutlet var txRef: UITextField!
    @IBOutlet var amount: UITextField!
    @IBOutlet var secretKey: UITextField!
    @IBOutlet var pubkey: UITextField!
    
    var isPinAuth = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EnterKeyViewController.doneTapped(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
        let tgr = UITapGestureRecognizer(target: self, action: #selector(EnterKeyViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tgr)
    }
    
    func handleTap(_ recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.isPinAuth = true
        }else {
            self.isPinAuth = false
        }
    }
    func doneTapped(_ sender:Any) {
        if (desc.text?.isEmpty)! || (email.text?.isEmpty)! || (appName.text?.isEmpty)! ||
            
            (txRef.text?.isEmpty)! || (amount.text?.isEmpty)! || (secretKey.text?.isEmpty)! || (pubkey.text?.isEmpty)! {
            let alert = UIAlertController(title: "Oooops", message: "Enter all field", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }else {
            
            let amount = Float(self.amount.text!)
            if amount == nil {
                let alert = UIAlertController(title: "Oooops", message: "Amount must be number", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let ravePaymentManager = RavePaymentManager(pubkey.text!, secretKey: secretKey.text!, appName: appName.text!, transactionDescription: desc.text!, amount:amount!, email: email.text!, txRef: txRef.text!)
            ravePaymentManager.country = "Nigeria"
            ravePaymentManager.isPinAuth = self.isPinAuth
            ravePaymentManager.logoImage = UIImage(named: "logo.jpg")
            ravePaymentManager.delegate = self
            ravePaymentManager.show()
        }
    }

}


extension EnterKeyViewController:RavePaymentManagerDelegate {
    
    func ravePaymentManagerDidCancel(_ ravePaymentManager: RavePaymentManager) {
        print("cancel")
    }
    
    func ravePaymentManager(_ ravePaymentManager: RavePaymentManager, didCompletePaymentWithResult result: RavePaymentResult) {
        print(result.status)
        print(result.message)
    }
}
