//
//  Utils.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import Foundation
import UIKit


class Utils{
    static let blueBG = UIColor(red: 0.33, green: 0.72, blue: 0.73, alpha: 1.00)
    
    func generateRandomId() -> Int {
        return Int.random(in: 1...999999)
    }
    
    func showToast(vc: UIViewController, message: String, time: Double, completion: @escaping() -> ()? ){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.8
        alert.view.layer.cornerRadius = 10
        vc.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+time) {
            alert.dismiss(animated: true)
            completion()
        }
    }
}

extension UIViewController{
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
