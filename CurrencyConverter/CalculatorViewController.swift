//
//  CalculatorViewController.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/22/17.
//  Copyright © 2017 Toes. All rights reserved.
//


/*
 
 V. Create a currency converter by utilizing data from the fixer.io API.
 The currency converter must include a currency selector at the top to use as the base currency and display updated currency rates based on the selected base currency. When a user taps on a currency, a calculation view should appear with the selected currency and base currency. Only the base currency field should be editable.
 Feel free to use any open source libraries.
 (Consider this project as if you were developing a component within a large-scaled project)
 
*/

import UIKit
import Foundation

class CalculatorViewController: UIViewController, UITextFieldDelegate {
    
    var base = String()
    var selected = String()
    var selectedRate = String()

    @IBOutlet weak var conversionLabel: UILabel!
    
    @IBOutlet weak var baseCurrency: UITextField!

    @IBOutlet weak var baseLabel: UILabel!
    
    @IBOutlet weak var selectedCurrency: UILabel!
    
    @IBOutlet weak var selectedLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseCurrency.becomeFirstResponder()
        
        // set up textfield/keyboard
        baseCurrency.keyboardType = .numberPad
        baseCurrency.borderStyle = .none
        baseCurrency.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        baseCurrency.text = "1.00"
        
        // set up labels
        conversionLabel.text = "1 \(base) = \(selectedRate) \(selected)"
        baseLabel.text = base
        selectedCurrency.text = selectedRate
        selectedLabel.text = selected
        
        // add borders to base and selected currency divisions
        let midLine = CALayer()
        midLine.frame = CGRect(x: 0, y: backgroundView.frame.height / 2, width: self.view.frame.width, height: 0.5)
        midLine.backgroundColor = UIColor.lightGray.cgColor
        backgroundView.layer.addSublayer(midLine)
        
        let topLine = CALayer()
        topLine.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5)
        topLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        backgroundView.layer.addSublayer(topLine)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: backgroundView.frame.height - 0.5, width: self.view.frame.width, height: 0.5)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        backgroundView.layer.addSublayer(bottomLine)
        
        
        // adds top line to keyboard
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        baseCurrency.inputAccessoryView = toolBar
        
        
        
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        baseCurrency.becomeFirstResponder()
//    }
    
    
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        baseCurrency.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
//    func doneNumberPad() {
//        print(baseCurrency.text)
//    }
    
    func textFieldDidChange() {

        let rateDouble = (selectedRate as NSString).doubleValue
        
        if let enteredText = baseCurrency.text {
            let baseDouble = (enteredText as NSString).doubleValue
            selectedCurrency.text = String(format: "%.2f", rateDouble * baseDouble)
            
        }
        
        
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

