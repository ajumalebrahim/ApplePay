//
//  ViewController.swift
//  ApplePay
//
//  Created by Ajumal Ebrahim on 8/21/17.
//  Copyright © 2017 Ajumal Ebrahim. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {

    @IBOutlet weak var applePayButton: UIView!
    let paymentHandler = ApplePayHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let result = ApplePayHandler.applePayStatus()
        var button: UIButton?
        if result.canMakePayments {
            button = PKPaymentButton(type: .buy, style: .black)
            button?.addTarget(self, action: #selector(ViewController.payPressed), for: .touchUpInside)
        } else if result.canSetupCards {
            button = PKPaymentButton(type: .setUp, style: .black)
            button?.addTarget(self, action: #selector(ViewController.setupPressed), for: .touchUpInside)
        } else {
            //
        }
        
        if button != nil {
            applePayButton.addSubview(button!)
            
            button?.translatesAutoresizingMaskIntoConstraints = false
            let attributes: [NSLayoutAttribute] = [.top, .bottom, .right, .left]
            NSLayoutConstraint.activate(attributes.map {
                NSLayoutConstraint(item: button as Any, attribute: $0, relatedBy: .equal, toItem: applePayButton, attribute: $0, multiplier: 1, constant: 0)
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
    
    func payPressed(sender: AnyObject) {
        paymentHandler.startPayment() { (succes) in
            if succes {
                
            } else {
                
            }
        }
    }

}

