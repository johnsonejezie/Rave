//
//  FlutterWavaPayManager.swift
//  flutterwave
//
//  Created by Johnson Ejezie on 10/12/2016.
//  Copyright © 2016 johnsonejezie. All rights reserved.
//

import UIKit

protocol RavePaymentManagerDelegate:class {
    func ravePaymentManagerDidCancel(_ ravePaymentManager:RavePaymentManager)
    func ravePaymentManager(_ ravePaymentManager:RavePaymentManager, didCompletePaymentWithResult result:RavePaymentResult)
}

enum PaymentMethod {
    case Card
    case Account
    case UserToken
}

enum ValidationType {
    case RandomDebit
    case Pin
    case OTP
    case Redirect
}

final class RavePaymentManager: UIViewController {
    
    weak var delegate:RavePaymentManagerDelegate?
    
    fileprivate var cardImage = UIImage(named: FWConstants.ImageNamed.CardBlack)
    fileprivate var cardImageView: UIImageView!
    fileprivate var validationType = ValidationType.OTP
    fileprivate var result:RavePaymentResult?
    fileprivate var isKeyboardVisible = false
    fileprivate var paymentMethod = PaymentMethod.Card
    
    
    @IBOutlet var pinTextField: UITextField!
    @IBOutlet fileprivate var companyLogoImageView: UIImageView!
    @IBOutlet var userTokenTextField: UITextField!
    @IBOutlet fileprivate var companyNameLabel: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    @IBOutlet fileprivate var costLabel: UILabel!
    
    @IBOutlet fileprivate var bankNameTextField: UITextField!
    @IBOutlet fileprivate var accountNumberTextField: UITextField!
    @IBOutlet fileprivate var cardNumberTextField: UITextField!
    @IBOutlet fileprivate var errorSuccessView: UIView!
    @IBOutlet fileprivate var errorSucessMessageLabel: UILabel!
    
    @IBOutlet fileprivate var segmentControl: UISegmentedControl!
    @IBOutlet fileprivate var payButton: UIButton!
    @IBOutlet fileprivate var otpTextField: UITextField!
    @IBOutlet fileprivate var expiryDateTextField: UITextField!
    
    @IBOutlet var checkBoxView: UIView!
    @IBOutlet var checkBox: CheckBox!
    @IBOutlet fileprivate var horizontalStackView: UIStackView!
    
    @IBOutlet var errorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var containerView: UIView!
    @IBOutlet fileprivate var cvvTextField: UITextField!
    @IBOutlet fileprivate var OTPValidationTextField: UITextField!
    
    @IBOutlet var userTokenCheckbox: CheckBox!
    
    @IBOutlet var useTokenView: UIView!
    
    @IBOutlet var useTokenCVV: UITextField!
    @IBOutlet var useTokenCheckboxHeightConstraint: NSLayoutConstraint!

    @IBOutlet var otpValidStackView: UIStackView!
    @IBOutlet var cardStackView: UIStackView!
    @IBOutlet var stackViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var accountStackView: UIStackView!
    
    @IBOutlet var tokenStackView: UIStackView!
    fileprivate var timer: Timer!
    
    fileprivate var activeTextField: UITextField?
    fileprivate let pickerView = UIPickerView()
    fileprivate var pickOption = [String]()
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    fileprivate var isCardTypeKnown = false
    fileprivate var isOTPValidation = false
    fileprivate var showUserToken = false
    fileprivate var amount:Float = 0.0
    fileprivate var name = ""
    fileprivate var transactionDescription = ""
    fileprivate var listOfBankNames = [String]()
    var PBFPubKey = ""
    var txRef = ""
    var email = ""
    var secretKey = ""
    fileprivate var userToken = ""
    
    var currency = ""
    var country = ""
    var firstname = ""
    var lastname = ""
    var IP:String?
    var narration = ""
    var passcode = ""
    var validateoption = ""
    var logoImage: UIImage?
    var meta = [[String:Any]]()
    var isPinAuth = false
    
    //MARK:- initialize rave
    convenience init(_ PBFPubKey:String, secretKey:String, appName:String?, transactionDescription:String?, amount:Float, email:String, txRef:String) {
        self.init(nibName: "RavePaymentManager", bundle: nil)
        if let name = appName {
            self.name = name
        }
        if let itemDesc = transactionDescription {
            self.transactionDescription = itemDesc
        }
        self.secretKey = secretKey
        self.PBFPubKey = PBFPubKey
        self.amount = amount
        self.email = email
        self.txRef = txRef
        self.transactionDescription = transactionDescription ?? ""
        cardImageView = UIImageView(image: cardImage)
        cardImageView.contentMode = .center
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        if self.isPinAuth == true {
            self.validationType = .Pin
            self.stackViewContainerHeightConstraint.constant = 190
            self.pinTextField.isHidden = false
        }else {
            self.stackViewContainerHeightConstraint.constant = 140
            self.pinTextField.isHidden = true
        }
        setUpUI()
        
        
        self.containerView.layer.cornerRadius = 5
        FWHelpers.getListOfBanks()
        checkBox.checked = {(checked) in
            self.showUserToken = checked
        }
        self.userTokenCheckbox.checked = {(checked) in
            self.useTokenCheckBoxTapped(checked)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.companyLogoImageView.layer.cornerRadius = self.companyLogoImageView.bounds.size.height/2
        self.companyLogoImageView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.masksToBounds = true
        self.errorSuccessView.layer.cornerRadius = 5
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForCurrentIP(interval: 10)
        addSpinner()
    }
    
    private func addSpinner()  {
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 15, height: 15)
        spinner.startAnimating()
        spinner.alpha = 0.0
        payButton.addSubview(spinner)
    }
    
    private func setUpUI() {
        setUpTextFields()
        setUpButton()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.handleViewTapped(_:)))
        self.view.addGestureRecognizer(tgr)
        
        self.accountNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        self.bankNameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.otpTextField.translatesAutoresizingMaskIntoConstraints = false
        self.errorSucessMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        self.expiryDateTextField.translatesAutoresizingMaskIntoConstraints = false
        self.cvvTextField.translatesAutoresizingMaskIntoConstraints = false
        self.userTokenTextField.translatesAutoresizingMaskIntoConstraints = false
        self.useTokenCVV.translatesAutoresizingMaskIntoConstraints = false
        self.OTPValidationTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.errorViewHeightConstraint.constant = 0
        self.errorSuccessView.isHidden = true

        self.companyNameLabel.text = self.name
        self.descriptionLabel.text = self.transactionDescription
        self.costLabel.text = FWHelpers.currentFormmatter(self.amount)
        self.companyLogoImageView.image = logoImage
        self.cardStackView.alpha = 1
        self.accountStackView.alpha = 0
        self.tokenStackView.alpha = 0
        self.otpValidStackView.alpha = 0
    }
    
    func useTokenCheckBoxTapped(_ isChecked:Bool) {
        if isChecked  {
            self.paymentMethod = .UserToken
            errorViewHeightConstraint.constant = 0
            errorSuccessView.isHidden = true
            UIView.animate(withDuration: 0.2, animations: {
                self.stackViewContainerHeightConstraint.constant = 90 //40 each, 5 spacing
                self.cardStackView.alpha = 0
                self.accountStackView.alpha = 0
                self.tokenStackView.alpha = 1
                self.hideErrorView()
            })
        }else {
            self.paymentMethod = .Card
            errorViewHeightConstraint.constant = 0
            errorSuccessView.isHidden = true
            UIView.animate(withDuration: 0.2, animations: {
                if self.isPinAuth == true {
                    self.stackViewContainerHeightConstraint.constant = 190
                    self.pinTextField.isHidden = false
                }else {
                    self.stackViewContainerHeightConstraint.constant = 140
                    self.pinTextField.isHidden = true
                } //40 each, 5 spacing
                self.cardStackView.alpha = 1
                self.accountStackView.alpha = 0
                self.tokenStackView.alpha = 0
            })
        }
        isOTPValidation = false
        payButton.setTitle("PAY \(FWHelpers.currentFormmatter(self.amount))", for: .normal)
    }
    
    @objc private func handleViewTapped(_ recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func checkForCurrentIP(interval: TimeInterval){
        if self.timer != nil { self.stopChecking() }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (_) in
            FWHelpers.getIP(completion: { ip in
                
                if self.IP != nil {
                    if self.IP != ip {
                        guard let ip = ip else {
                            return
                        }
                        self.IP = ip
                    }
                }else {
                    guard let ip = ip else {
                        return
                    }
                    self.IP = ip
                }
            })
            
        })
        // Execute timer immediately (don't wait for first interval)
        self.timer.fire()
    }
    
    fileprivate func stopChecking(){
        if self.timer == nil {
            return
        }
        self.timer.invalidate()
        self.timer = nil
        
    }
    
    private func setUpButton() {
        payButton.backgroundColor = FWConstants.Color.flutterGreenColor
        payButton.layer.cornerRadius = 5
        payButton.setTitle("PAY \(FWHelpers.currentFormmatter(self.amount))", for: .normal)
        payButton.addTarget(self, action: #selector(RavePaymentManager.pay(_:)), for: .touchUpInside)
        payButton.setTitleColor(.white, for: .normal)
    }
    
    private func setUpTextFields() {
        //Card Number
        let cardTypeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        cardTypeView.addSubview(cardImageView)
        cardNumberTextField.rightViewMode = .always
        cardNumberTextField.rightView = cardTypeView
        cardNumberTextField.borderStyle = .none
        cardNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
        cardNumberTextField.layer.borderWidth = 1
        cardNumberTextField.placeholder = FWConstants.Text.CardNumberTextFieldPlaceholder
        cardNumberTextField.delegate = self
        cardNumberTextField.layer.cornerRadius = 4
        
        //Expiry month and year
        expiryDateTextField.borderStyle = .none
        expiryDateTextField.layer.borderColor = UIColor.lightGray.cgColor
        expiryDateTextField.layer.borderWidth = 1
        expiryDateTextField.placeholder = FWConstants.Text.ExpiryDateTextFieldPlaceholder
        expiryDateTextField.delegate = self
        expiryDateTextField.layer.cornerRadius = 4
        
        //CVV
        cvvTextField.borderStyle = .none
        cvvTextField.layer.borderColor = UIColor.lightGray.cgColor
        cvvTextField.layer.borderWidth = 1
        cvvTextField.layer.cornerRadius = 4
        cvvTextField.placeholder = FWConstants.Text.CVVTextFieldPlaceholder
        cvvTextField.delegate = self
        
        
        OTPValidationTextField.borderStyle = .none
        OTPValidationTextField.layer.borderColor = UIColor.lightGray.cgColor
        OTPValidationTextField.layer.borderWidth = 1
        OTPValidationTextField.layer.cornerRadius = 4
        OTPValidationTextField.delegate = self
        
        pinTextField.borderStyle = .none
        pinTextField.layer.borderColor = UIColor.lightGray.cgColor
        pinTextField.layer.borderWidth = 1
        pinTextField.layer.cornerRadius = 4
        pinTextField.delegate = self
        
        //USer token CVV
        useTokenCVV.borderStyle = .none
        useTokenCVV.layer.borderColor = UIColor.lightGray.cgColor
        useTokenCVV.layer.borderWidth = 1
        useTokenCVV.layer.cornerRadius = 4
        useTokenCVV.placeholder = FWConstants.Text.CVVTextFieldPlaceholder
        useTokenCVV.delegate = self
        
        //USER TOKEN
        userTokenTextField.borderStyle = .none
        userTokenTextField.layer.borderColor = UIColor.lightGray.cgColor
        userTokenTextField.layer.borderWidth = 1
        userTokenTextField.layer.cornerRadius = 4
        userTokenTextField.placeholder = FWConstants.Text.UserTokenTextFieldPlaceholder
        userTokenTextField.delegate = self
        
        //Acount number
        accountNumberTextField.borderStyle = .none
        accountNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
        accountNumberTextField.layer.borderWidth = 1
        accountNumberTextField.layer.cornerRadius = 4
        accountNumberTextField.placeholder = FWConstants.Text.AccountNumberTextFieldPlaceholder
        accountNumberTextField.delegate = self
        
        let dropdown = UIImage(named: FWConstants.ImageNamed.DropDown)
        let otpDropDownButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30 ))
        otpDropDownButton.setImage(dropdown, for: .normal)
        otpDropDownButton.addTarget(self, action: #selector(self.onOtpDropDownButtonTapped(_:)), for: .touchUpInside)
        
        //OTP texfield
        otpTextField.rightViewMode = .always
        otpTextField.rightView = otpDropDownButton
        otpTextField.borderStyle = .none
        otpTextField.layer.borderColor = UIColor.lightGray.cgColor
        otpTextField.layer.borderWidth = 1
        otpTextField.layer.cornerRadius = 4
        otpTextField.delegate = self
        otpTextField.inputView = pickerView
        otpTextField.text = FWConstants.otpOptions[0]
        
        let bankDropDownButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30 ))
        bankDropDownButton.setImage(dropdown, for: .normal)
        bankDropDownButton.addTarget(self, action: #selector(self.onBankDropDownButtonTapped(_:)), for: .touchUpInside)
        //Bank Name texfield
        bankNameTextField.rightViewMode = .always
        bankNameTextField.rightView = bankDropDownButton
        bankNameTextField.borderStyle = .none
        bankNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        bankNameTextField.layer.borderWidth = 1
        bankNameTextField.layer.cornerRadius = 4
        bankNameTextField.delegate = self
        bankNameTextField.inputView = pickerView
        
        bankNameTextField.text = "SELECT BANK"
        
    }
    
    func addDoneButtonOnKeyboard(_ textField:UITextField) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(RavePaymentManager.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func onOtpDropDownButtonTapped(_ sender:UIButton) {
        otpTextField.becomeFirstResponder()
    }
    
    func onBankDropDownButtonTapped(_ sender:UIButton) {
        bankNameTextField.becomeFirstResponder()
    }
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.delegate?.ravePaymentManagerDidCancel(self)
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func onSegmentedChange(_ sender: UISegmentedControl) {
        isOTPValidation = false
        switch sender.selectedSegmentIndex {
        case 0:
            self.paymentMethod = .Card
            errorViewHeightConstraint.constant = 0
            errorSuccessView.isHidden = true
            UIView.animate(withDuration: 0.2, animations: {
                self.useTokenCheckboxHeightConstraint.constant = 30
                self.userTokenCheckbox.isChecked = false
                if self.isPinAuth == true {
                    self.stackViewContainerHeightConstraint.constant = 190
                    self.pinTextField.isHidden = false
                }else {
                    self.stackViewContainerHeightConstraint.constant = 140
                    self.pinTextField.isHidden = true
                }
                self.cardStackView.alpha = 1
                self.accountStackView.alpha = 0
                self.tokenStackView.alpha = 0
                self.useTokenView.alpha = 1
            })
            
        case 1:
            self.paymentMethod = .Account
            self.showUserToken = false
            errorViewHeightConstraint.constant = 0
            useTokenCheckboxHeightConstraint.constant = 0
            errorSuccessView.isHidden = true
            UIView.animate(withDuration: 0.2, animations: {
                self.stackViewContainerHeightConstraint.constant = 140
                self.useTokenCheckboxHeightConstraint.constant = 0
                self.cardStackView.alpha = 0
                self.accountStackView.alpha = 1
                self.tokenStackView.alpha = 0
                self.useTokenView.alpha = 0
                
            })
        default:
            break
        }
        
    }
    
    fileprivate func switchPayButton(_ enable: Bool) {
        if enable {
            payButton.isEnabled = true
            payButton.backgroundColor = FWConstants.Color.flutterGreenColor
            self.spinner.alpha = 0
        } else {
            payButton.isEnabled = false
            payButton.backgroundColor = UIColor.gray
            payButton.setTitle("Please wait...", for: .normal)
            self.spinner.alpha = 1
        }
    }
    
    lazy var FWTransitioningDelegate = FWPresentationManager()
    public func show(){
        let window = UIWindow.visibleWindow()
        self.transitioningDelegate = FWTransitioningDelegate
        self.modalPresentationStyle = .custom
        
        window?.rootViewController?.present(self, animated: true, completion: nil)
        
    }
    
}


fileprivate extension RavePaymentManager {
    fileprivate  func validateInput() -> Bool {
        if self.paymentMethod == .Card {
            if cardNumberTextField.text!.isEmpty {
                errorSucessMessageLabel.text = "Card number can not be empty"
                return false
            }else if cvvTextField.text!.isEmpty {
                errorSucessMessageLabel.text = "CVV can not be empty"
                return false
            }else if expiryDateTextField.text!.isEmpty {
                errorSucessMessageLabel.text = "Expiry date can not be empty"
                return false
            }else {
                errorSucessMessageLabel.text = ""
                return true
            }
        }else if self.paymentMethod == .Account {
            if accountNumberTextField.text!.isEmpty {
                errorSucessMessageLabel.text = "Account number can not be empty"
                return false
            }else if bankNameTextField.text?.uppercased() == "SELECT BANK" {
                errorSucessMessageLabel.text = "Please select bank."
                return false
            }else if otpTextField.text?.uppercased() == "SELECT OTP OPTION" {
                errorSucessMessageLabel.text = "Please select OTP option"
                return false
            }else {
                errorSucessMessageLabel.text = ""
                return true
            }
        }else {
            if userTokenTextField.text!.isEmpty {
                errorSucessMessageLabel.text = "Token can not be empty"
                return false
            }else if useTokenCVV.text!.isEmpty {
                errorSucessMessageLabel.text = "CVV can not be empty"
                return false
            }else {
                errorSucessMessageLabel.text = ""
                return true
            }
        }
    }
    
    fileprivate func transactionCompleted(_ message:String) {
        DispatchQueue.main.async {
            if self.showUserToken == true {
               self.errorSucessMessageLabel.text = message + "\n" + "Your token is: \(self.userToken). Use it for quick payment."
            }else {
                self.errorSucessMessageLabel.text = message
            }
            var height = self.heightForView(text: self.errorSucessMessageLabel.text!, font: self.errorSucessMessageLabel.font, width: self.errorSucessMessageLabel.bounds.size.width)
            if height < 50 {
                height = 50
            }
            self.payButton.setTitle("Completed", for: .normal)
            self.spinner.stopAnimating()
            self.spinner.alpha = 0
            self.payButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.errorSuccessView.isHidden = false
                self.errorViewHeightConstraint.constant = height
                
            }, completion: { success in
                
            })
        }
    }
    
    fileprivate func showErrorOrSuccessViewWith(_ message:String?, hideErrorView:Bool) {
        DispatchQueue.main.async {
            if message != nil {
               self.errorSucessMessageLabel.text = message!
            }
            
            var height = self.heightForView(text: self.errorSucessMessageLabel.text!, font: self.errorSucessMessageLabel.font, width: self.errorSucessMessageLabel.bounds.size.width)
            if height < 50 {
                height = 50
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.errorSuccessView.isHidden = false
                self.errorViewHeightConstraint.constant = height
                
            }, completion: { success in
                if hideErrorView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.hideErrorView()
                    })
                }
            })
        }
    }
    
    fileprivate func hideErrorView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorViewHeightConstraint.constant = 0
            self.errorSuccessView.isHidden = true
        })
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @objc func pay(_ sender: AnyObject) {
        
        spinner.center = CGPoint(x: 40.0, y: self.payButton.frame.size.height/2)
        
        if isOTPValidation == true {
            self.switchDependingOnValidationType()
        }else {
            let isValid = validateInput()
            
            if isValid == false {
                self.showErrorOrSuccessViewWith(nil, hideErrorView:true)
                self.switchPayButton(true)
                return
            }
            
            var dictionary:[String:String]?
            
            switch self.paymentMethod {
            case .Account:
                dictionary = getAccountPaymentRequiredParam()
            case .Card:
                dictionary = getCardPaymentRequiredParam()
            case .UserToken:
                dictionary = getTokenPaymentRequiredParam()
            
            }
            
            guard let dict = dictionary else {
                self.switchPayButton(true)
                return
            }
            self.view.endEditing(true)
            self.switchPayButton(false)
            
            let allParam = includeNotRequiredParam(dictionary: dict)
            
            let jsonString = FWHelpers.jsonStringify(allParam, prettyPrinted: false)
            let encryptKey = FWHelpers.getEncryptionKey(secretKey)
            
            let clientdata = TripleDES.encrypt(string: jsonString, key: encryptKey)
            
            let str = clientdata?.base64EncodedString(options: [])
            
            let resource = payResource(PBFPubKey, encryptedString: str!)
            self.charge(resource: resource)
        }
        
        
    }
    
    fileprivate func processSuccessCharge(for result:RavePaymentResult) {
        self.txRef = result.data.txRef
        if self.paymentMethod == .Card || self.paymentMethod == .UserToken {
            switch result.data.authModelUsed {
            case .NOAUTH:
                self.errorSuccessView.backgroundColor = FWConstants.Color.flutterGreenColor
                self.switchPayButton(true)
                self.transactionCompleted(result.status)
                self.delegate?.ravePaymentManager(self, didCompletePaymentWithResult: result)
                break
            case .VBVSECURECODE:
                self.isOTPValidation = true
                self.switchPayButton(true)
                self.validationType = .Redirect
                self.errorSuccessView.backgroundColor = FWConstants.Color.flutterGreenColor
                self.showErrorOrSuccessViewWith("Tap continue to be redirected to a secure page to authenticate transaction. Click done when authentication is complete.", hideErrorView: false)
                self.payButton.setTitle("CONTINUE", for: .normal)
            case .RANDOMDEBIT:
                self.isOTPValidation = true
                self.validationType = .RandomDebit
                self.showOTPView()
            case .PIN:
                self.isOTPValidation = true
                self.validationType = .Pin
                self.showOTPView()
            }
        }else {
            self.isOTPValidation = true
            self.showOTPView()
        }
        
    }
    
    fileprivate func showOTPView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.switchPayButton(true)
            self.cardStackView.alpha = 0
            self.useTokenView.alpha = 0
            self.accountStackView.alpha = 0
            self.tokenStackView.alpha = 0
            self.otpValidStackView.alpha = 1
            self.errorViewHeightConstraint.constant = 0
            self.errorSuccessView.isHidden = true
            self.stackViewContainerHeightConstraint.constant = 50
            self.OTPValidationTextField.isHidden = false
            if self.validationType == .OTP {
                self.OTPValidationTextField.placeholder = "Enter token sent to you"
            }else if self.validationType == .RandomDebit   {
                self.OTPValidationTextField.placeholder = "Enter the amount deducted from your card."
            }else {
                self.OTPValidationTextField.placeholder = "Enter token sent to you"
            }
            self.payButton.setTitle("VALIDATE", for: .normal)
        })
    }
    
    fileprivate func authURLRedirect(_ authurl:String) {
        let fullURL = authurl.replacingOccurrences(of: " ", with: "%20")
        
        let webView = RedirectVC(nibName: "RedirectVC", bundle: nil)
        webView.url = fullURL
        webView.completedRedirect = { (jsonString) in
            guard let jsonString = jsonString else {
                self.showErrorOrSuccessViewWith("Uknown error", hideErrorView: true)
                return
            }
            self.verifyRedirectResponse(jsonString)
        }
        let nc = UINavigationController(rootViewController: webView)
        present(nc, animated: true, completion: nil)
        
    }
    
    fileprivate func removeChildController(controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    fileprivate func validateResource(payload:[String:Any]) -> Resource<RavePaymentResult> {
        let url = URL(string: FWConstants.ValidateAccountCharge)!
        return Resource(url: url, method: .post(payload), parseJSON: { json in
            if let dict = json as? [String:Any] {
                let status = dict["status"] as? String
                let message = dict["message"] as? String
                let payData: RaveResponseData
                if let data = dict["data"] as? [String:Any] {
                    payData = RaveResponseData(json: data)!
                }else {
                    payData = RaveResponseData()
                }
                let response = RavePaymentResult(status: status!, message: message!, data: payData)
                return response
            }
            return nil
        })
    }
    
    fileprivate func payResource (_ pubKey:String, encryptedString:String) -> Resource<RavePaymentResult> {
        let payload = [
            "PBFPubKey":pubKey,
            "client":encryptedString,
            "alg":"3DES-24"
        ]
        let url = URL(string: FWConstants.PayEndPoint)!
        return Resource(url: url, method: .post(payload), parseJSON: { json in
            if let dict = json as? [String:Any] {
                let status = dict["status"] as? String
                let message = dict["message"] as? String
                let payData: RaveResponseData
                if let data = dict["data"] as? [String:Any] {
                    payData = RaveResponseData(json: data)!
                }else {
                    payData = RaveResponseData()
                }
                let response = RavePaymentResult(status: status!, message: message!, data: payData)
                return response
            }
            return nil
        })
    }
}


//MARK:- Get params for each payment type
extension RavePaymentManager {
    fileprivate func getCardPaymentRequiredParam() -> [String:String]? {
        self.stopChecking()
        guard let ip = IP else {
            self.showErrorOrSuccessViewWith("Failed to get network IP", hideErrorView:true)
            return nil
        }
        let expiryDate = self.expiryDateTextField.text!
        let stringArray = expiryDate.components(separatedBy: "/")
        
        if stringArray.count != 2 {
            self.showErrorOrSuccessViewWith("Please enter expiry date in the format 09/18", hideErrorView:true)
            
            return nil
        }
        
        let expiryMonth = stringArray[0]
        let expiryYear = stringArray[1]
        
        var dictionary = [String:String]()
        dictionary["PBFPubKey"] = PBFPubKey
        dictionary["cardno"] = self.cardNumberTextField.text!.replacingOccurrences(of: " ", with: "")
        dictionary["cvv"] = self.cvvTextField.text!
        if self.isPinAuth {
            dictionary["pin"] = self.pinTextField.text!
        }
        dictionary["amount"] = "\(amount)"
        
        dictionary["expiryyear"] = expiryYear
        dictionary["expirymonth"] = expiryMonth
        
        dictionary["email"] = email
        dictionary["IP"] = ip
        dictionary["txRef"] = txRef
        
        return dictionary
    }
    
    fileprivate func getTokenPaymentRequiredParam() -> [String:String]? {
        self.stopChecking()
        guard let ip = IP else {
            self.showErrorOrSuccessViewWith("Failed to get network IP", hideErrorView:true)
            return nil
        }
        
        var dictionary = [String:String]()
        dictionary["PBFPubKey"] = PBFPubKey
        dictionary["shortcode"] = self.userTokenTextField.text!
        dictionary["cvv"] = self.useTokenCVV.text!
        dictionary["amount"] = "\(amount)"
        dictionary["email"] = email
        dictionary["IP"] = ip
        dictionary["txRef"] = txRef
        
        return dictionary
    }
    
    fileprivate func getAccountPaymentRequiredParam() -> [String:String]? {
        self.stopChecking()
        guard let ip = IP else {
            self.showErrorOrSuccessViewWith("Failed to get network IP", hideErrorView:true)
            return nil
        }
        
        var dictionary = [String:String]()
        dictionary["PBFPubKey"] = PBFPubKey
        dictionary["accountnumber"] = self.accountNumberTextField.text!
        dictionary["accountbank"] = FWHelpers.getCodeForBank(self.bankNameTextField.text!)
        dictionary["amount"] = "\(amount)"
        dictionary["payment_type"] = "account"
        dictionary["email"] = email
        dictionary["IP"] = ip
        dictionary["txRef"] = txRef
        return dictionary
    }
    
    fileprivate func includeNotRequiredParam(dictionary:[String:String])-> [String:Any] {
        var dict:[String:Any] = dictionary
        if self.currency == "" {
            currency = "NGN"
        }
        dict["country"] = country == "" ? "Nigeria":self.country
        dict["currency"] = currency //== "" ? "NGN":self.currency
        dict["firstname"] = firstname
        dict["lastname"] = lastname
        dict["narration"] = narration
        dict["meta"] = meta
        if self.paymentMethod == .Account {
            dict["passcode"] = passcode
            dict["validateoption"] = otpTextField.text!
        }
        return dict
    }
}

//MARK:- Network actions
extension RavePaymentManager {
    
    fileprivate func charge(resource:Resource<RavePaymentResult>) {
        FWRequest().load(resource: resource, completion: { result in
            guard let result = result else { return }
            self.result = result
            if result.status == "success" {
                if result.data.chargeResponseCode == "02" {
                    DispatchQueue.main.async {
                        if let chargeToken = result.data
                            .chargeToken {
                            self.userToken = chargeToken.shortcode
                        }
                        self.processSuccessCharge(for: result)
                    }
                }else if result.data.chargeResponseCode == "00" {
                    DispatchQueue.main.async {
                        if let chargeToken = result.data
                            .chargeToken {
                            self.userToken = chargeToken.shortcode
                        }
                        self.errorSuccessView.backgroundColor = FWConstants.Color.flutterGreenColor
                        self.transactionCompleted(result.status)
                        var finalResult = result
                        finalResult.message = result.data.status
                        self.delegate?.ravePaymentManager(self, didCompletePaymentWithResult: finalResult)
                    }
                }
            }else {
                DispatchQueue.main.async {
                    self.showErrorOrSuccessViewWith(result.message, hideErrorView:true)
                    self.switchPayButton(true)
                    self.payButton.setTitle("PAY \(FWHelpers.currentFormmatter(self.amount))", for: .normal)
                    return
                }
            }
        })
    }
    
    fileprivate func verifyRedirectResponse(_ response:String) {
        guard let data = response.data(using: .utf8) else {
            return
        }
        self.switchPayButton(false)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            DispatchQueue.main.async {
                if let json = json as? [String:Any] {
                    let message = json["vbvrespmessage"] as? String
                    if let vbvrespcode = json["vbvrespcode"] as? String {
                        if vbvrespcode == "00" || vbvrespcode == "0" {
                            self.errorSuccessView.backgroundColor = FWConstants.Color.flutterGreenColor
                            self.transactionCompleted(message ?? "")
                            self.payButton.isEnabled = false
                            let data = RaveResponseData()
                            let finalResult = RavePaymentResult(status:"success", message:message ?? "", data:data)
                            self.delegate?.ravePaymentManager(self, didCompletePaymentWithResult: finalResult)
                        }else {
                            self.errorSuccessView.backgroundColor = FWConstants.Color.ErrorColor
                            self.showErrorOrSuccessViewWith(message, hideErrorView:true)
                            self.payButton.setTitle("PAY \(FWHelpers.currentFormmatter(self.amount))", for: .normal)
                            self.switchPayButton(true)
                        }
                        
                    }
                }
            }
            
        }catch let error {
            DispatchQueue.main.async {
                self.showErrorOrSuccessViewWith(error.localizedDescription, hideErrorView:true)
                self.spinner.alpha = 0
                self.payButton.setTitle("PAY \(FWHelpers.currentFormmatter(self.amount))", for: .normal)
                self.switchPayButton(true)
            }
        }
    }
    
    fileprivate func switchDependingOnValidationType() {
        guard let result = result else {
            return
        }
        switch self.validationType {
        case .RandomDebit:
            randomChargeValidation(result: result)
        case .Redirect:
            authURLRedirect(result.data.authurl)
        case .Pin:
            pinChargeValidation(result: result)
            break
        case .OTP:
            accountChargeValidation(result: result)
            break
        }
    }
    
    fileprivate func randomChargeValidation(result:RavePaymentResult) {
        if OTPValidationTextField.text!.isEmpty {
            self.showErrorOrSuccessViewWith("Enter the amount deducted from your card.", hideErrorView:true)
            return
        }
        let payload = [
            "PBFPubKey":PBFPubKey,
            "transaction_reference":result.data.flwRef,
            "txRef":self.txRef,
            "otp":Double(self.OTPValidationTextField.text!)!
        ] as [String : Any]
        let resource = validateResource(payload: payload)
        validateCharge(resource: resource)
    }
    
    fileprivate func pinChargeValidation(result:RavePaymentResult) {
        if OTPValidationTextField.text!.isEmpty {
            self.showErrorOrSuccessViewWith("OTP is required.", hideErrorView:true)
            return
        }
        let payload = [
            "PBFPubKey":PBFPubKey,
            "txRef":self.txRef,
            "otp":self.OTPValidationTextField.text!
        ]
        let resource = validateResource(payload: payload)
        validateCharge(resource: resource)
    }
    
    fileprivate func accountChargeValidation(result:RavePaymentResult) {
        if OTPValidationTextField.text!.isEmpty {
            self.showErrorOrSuccessViewWith("OTP is required.", hideErrorView:true)
            return
        }
        let payload = [
            "PBFPubKey":PBFPubKey,
            "txRef":self.txRef,
            "otp":self.OTPValidationTextField.text!
        ]
        let resource = validateResource(payload: payload)
        validateCharge(resource: resource)
    }
    
    fileprivate func validateCharge(resource:Resource<RavePaymentResult>) {
        self.view.endEditing(true)
        self.switchPayButton(false)
        FWRequest().load(resource: resource, completion: { result in
            guard let result = result else { return }
            self.result = result
            if result.status == "success" {
                var success = false
                if self.validationType == .RandomDebit || self.validationType == .Pin {
                    if result.data.vbvrespcode == "00" {
                        success = true
                    }
                }else {
                    if result.data.acctvalrespcode == "00" {
                        success = true
                    }
                }
                if success {
                    DispatchQueue.main.async {
                        self.errorSuccessView.backgroundColor = FWConstants.Color.flutterGreenColor
                        self.transactionCompleted(result.message)
                        self.switchPayButton(false)
                        self.delegate?.ravePaymentManager(self, didCompletePaymentWithResult: result)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.showErrorOrSuccessViewWith(result.data.acctvalrespmsg, hideErrorView:true)
                        self.switchPayButton(true)
                        self.payButton.setTitle("VALIDATE OTP", for: .normal)
                        return
                    }
                }
            }else {
                DispatchQueue.main.async {
                    self.showErrorOrSuccessViewWith(result.message, hideErrorView:true)
                    self.switchPayButton(true)
                    self.payButton.setTitle("VALIDATE OTP", for: .normal)
                    return
                }
            }
        })
        
    }
}

extension RavePaymentManager:UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeTextField?.text = pickOption[row]
    }
    
}

extension RavePaymentManager:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        self.addDoneButtonOnKeyboard(textField)
        if textField == otpTextField {
            pickOption = FWConstants.otpOptions
            pickerView.reloadAllComponents()
        }
        if textField == bankNameTextField {
            pickOption = FWConstants.listOfBankNames
            pickerView.reloadAllComponents()
        }
        
        //move textfields up
        let myScreenRect: CGRect = UIScreen.main.bounds
        let keyboardHeight : CGFloat = 216
        
        UIView.beginAnimations( "animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (textField.frame.origin.y + textField.frame.size.height +
            UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height +
                UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        frame.origin.y = -(needToMove+50) //add toolbar height
        self.view.frame = frame
        UIView.commitAnimations()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.beginAnimations( "animateView", context: nil)
        var frame : CGRect = self.view.frame
        frame.origin.y = (self.presentingViewController!.view!.frame.height - frame.size.height)/2.0
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == otpTextField || textField == bankNameTextField {
            return false
        }
        if textField == expiryDateTextField {
            if string.isEmpty && textField.text?.characters.count == 3 {
                let text = textField.text
                textField.text = text?.replacingOccurrences(of: "/", with: "")
            }
        }
        return true
    }
}


//MARK:- Format card
extension RavePaymentManager {
    fileprivate func reformatAsCardNumber(textField:UITextField){
        let formatter = CreditCardFormatter()
        formatter.formatToCreditCardNumber(textField: textField, withPreviousTextContent: textField.text, andPreviousCursorPosition: textField.selectedTextRange)
    }
    fileprivate func cardType(text:String) {
        let index = text.index(text.startIndex, offsetBy: 1)
        let firstDigit = text.substring(to: index)
        if Int(firstDigit) == 4 {
            UIView.animate(withDuration: 0.2, animations: {
                self.cardImageView.image = UIImage(named: FWConstants.ImageNamed.Visa)

            })
            isCardTypeKnown = true
            
        }else {
            if text.characters.count == 2 {
                let index = text.index(text.startIndex, offsetBy: 2)
                let firstTwoDigit = text.substring(to: index)
                
                if Int(firstTwoDigit)! >= 51 && Int(firstTwoDigit)! <= 55 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.cardImageView.image = UIImage(named: FWConstants.ImageNamed.MasterCard)
                    })
                    isCardTypeKnown = true
                }else {
                    self.cardImageView.image = cardImage
                }
            }
            
            
        }
    }
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        switch sender {
        case cardNumberTextField:
            if !cardNumberTextField.text!.isEmpty {
                reformatAsCardNumber(textField: cardNumberTextField)
                if isCardTypeKnown == false {
                    cardType(text: cardNumberTextField.text!)
                }
            }else {
                isCardTypeKnown = false
                self.cardImageView.image = cardImage
            }
            break
        case expiryDateTextField:
            var text = sender.text!
            
            if (text.characters.count == 2) {
                
                sender.text = text.appending("/")
                
            }
        default:
            break
        }
    }
}


