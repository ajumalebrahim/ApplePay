//
//  ApplePayHandler.swift
//  ApplePay
//
//  Created by Ajumal Ebrahim on 8/22/17.
//  Copyright © 2017 Ajumal Ebrahim. All rights reserved.
//

import UIKit
import PassKit
public typealias PaymentCompletionHandler = (Bool) -> Void

//public typealias URLRequestClosure = (URLResponse?, Data?, Error?) -> Void


class ApplePayHandler: NSObject {
    
    struct Merchant {
        static let sandbox = "merchant.sandbox.com.6alabat.cuisineApp"
        static let production = "merchant.com.6alabat.cuisineApp"
    }
    
    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa
    ]
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler?
    var fromView : UIViewController?
    
    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        if #available(iOS 10.0, *) {
            return (PKPaymentAuthorizationController.canMakePayments(),
                    PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
        } else {
            return (PKPaymentAuthorizationViewController.canMakePayments(),
                    PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks))
        }
    }
    
    func startPayment(completion: @escaping PaymentCompletionHandler) {
        
        let fare = PKPaymentSummaryItem(label: "Minimum Fare", amount: NSDecimalNumber(string: "9.99"), type: .final)
        let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
        let total = PKPaymentSummaryItem(label: "Talabat", amount: NSDecimalNumber(string: "10.99"), type: .pending)
        
        paymentSummaryItems = [fare, tax, total];
        self.completionHandler = completion
        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = ApplePayHandler.Merchant.sandbox
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
//        paymentRequest.requiredShippingAddressFields = [.phone, .email]
        paymentRequest.supportedNetworks = ApplePayHandler.supportedNetworks
        
        // Display our payment request
        if #available(iOS 10.0, *) {
            let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
            paymentController.delegate = self
            paymentController.present(completion: { (presented: Bool) in
                if presented {
                    NSLog("Presented payment controller")
                } else {
                    NSLog("Failed to present payment controller")
                    self.completionHandler!(false)
                }
            })
        } else {
            let paymentController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentController.delegate = self
            paymentController.present(fromView!, animated: true, completion: {
                
            })
        }
    }
}

/*
 PKPaymentAuthorizationControllerDelegate conformance.
 */
@available(iOS 10.0, *)
extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
//    @available(iOS 11.0, *)
//    private func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
//        
//    }
    
    @available(iOS 10.0, *)
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Perform some very basic validation on the provided contact information
//        if payment.shippingContact?.emailAddress == nil || payment.shippingContact?.phoneNumber == nil {
//            paymentStatus = .invalidShippingContact
//        } else {
//            // Here you would send the payment token to your server or payment provider to process
//            // Once processed, return an appropriate status in the completion handler (success, failure, etc)
            paymentStatus = .success
//        }
        
        completion(paymentStatus)
    }
    
    @available(iOS 10.0, *)
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
    
//    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
//        // The didSelectPaymentMethod delegate method allows you to make changes when the user updates their payment card
//        // Here we're applying a $2 discount when a debit card is selected
//        if paymentMethod.type == .debit {
//            var discountedSummaryItems = paymentSummaryItems
//            let discount = PKPaymentSummaryItem(label: "Debit Card Discount", amount: NSDecimalNumber(string: "-2.00"))
//            discountedSummaryItems.insert(discount, at: paymentSummaryItems.count - 1)
//            if let total = paymentSummaryItems.last {
//                total.amount = total.amount.subtracting(NSDecimalNumber(string: "5.00"))
//            }
//            completion(discountedSummaryItems)
//        } else {
//            completion(paymentSummaryItems)
//        }
//    }
}


extension ApplePayHandler: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        paymentStatus = .success
        completion(paymentStatus)
    }
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            if self.paymentStatus == .success {
                self.completionHandler!(true)
            } else {
                self.completionHandler!(false)
            }
        }
    }
}
