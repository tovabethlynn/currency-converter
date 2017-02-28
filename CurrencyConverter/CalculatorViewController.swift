//
//  CalculatorViewController.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/22/17.
//  Copyright © 2017 Toes. All rights reserved.
//

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
        baseLabel.text = base
        selectedCurrency.text = selectedRate
        selectedLabel.text = selected
        
        let mutableString = NSMutableAttributedString()
        mutableString.append(NSAttributedString(string: "1 \(base) equals\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.darkGray]))
        mutableString.append(NSAttributedString(string: "\(selectedRate) \(selected)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0), NSForegroundColorAttributeName: UIColor(colorLiteralRed: 0x25/255, green: 0x25/255, blue: 0x25/255, alpha: 1)]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.firstLineHeadIndent = 15
        paragraphStyle.headIndent = 15
        mutableString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, mutableString.length))
        conversionLabel.attributedText = mutableString
        
        
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set up gesture recognizer to cancel view on tap outside of view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        gesture.cancelsTouchesInView = false
        self.view.window?.addGestureRecognizer(gesture)
        
    }
    
    
    func dismissView(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            let location: CGPoint = sender.location(in: nil)
            
            if !self.view.point(inside: self.view.convert(location, from: self.view.window), with: nil) {
                self.view.window?.removeGestureRecognizer(sender)
                done(self)
            }
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeCalc"), object: self, userInfo: nil)
        baseCurrency.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
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

