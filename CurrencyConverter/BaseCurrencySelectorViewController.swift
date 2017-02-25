//
//  BaseCurrencySelectorViewController.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/22/17.
//  Copyright © 2017 Toes. All rights reserved.
//

import UIKit

class BaseCurrencySelectorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var countries = [String]()
    var currentSelection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(currentSelection, inComponent: 0, animated: false)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set up gesture recognizer to cancel view on tap outside of view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        gesture.cancelsTouchesInView = false
        self.view.window?.addGestureRecognizer(gesture)
    }
    
    
    func dismissPicker(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            let location: CGPoint = sender.location(in: nil)
            
            if !self.view.point(inside: self.view.convert(location, from: self.view.window), with: nil) {
                self.view.window?.removeGestureRecognizer(sender)
                cancel(self)
            }
        }
    }
    
    
    @IBAction func makeSelection(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBase"), object: self, userInfo: ["selected" : countries[pickerView.selectedRow(inComponent: 0)]] as [AnyHashable: Any])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBase"), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width / 3
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
