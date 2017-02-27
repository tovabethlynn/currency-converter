//
//  CurrencyTableViewController.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/22/17.
//  Copyright © 2017 Toes. All rights reserved.
//

import UIKit
import Foundation

class CurrencyTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var currencySelector: UIButton!

    var base = "USD"
    var countries = [String]()
    var rates = [String]()
    
    let dimView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()  // crashing when loads, need to do dispatch_async? also, can make faster?
        
        currencySelector.setTitle(base, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBase(notification:)), name: NSNotification.Name(rawValue: "updateBase"), object: nil)
        
    }
    
    
    func loadData() {
        
        let urlString = "https://api.fixer.io/latest?base=\(base)"
        guard let url = URL(string: urlString) else {
            print("URL error")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            guard let responseData = data else {
                print("No data")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String:AnyObject]
                print(json)
                if let rates = json["rates"] as? [String:Any] {
                    
                    let countryList = rates.keys
                    self.countries = countryList.sorted { $0 < $1 }
                    
                    self.rates = self.countries.map({ (country) -> String in
                        var formattedRate = NumberFormatter.localizedString(from: rates[country] as! NSNumber, number: .currency)
                        formattedRate.remove(at: formattedRate.startIndex)  // remove dollar sign
                        return formattedRate
                        
                    })
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
                
            } catch {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
        
    }
    
    
    func updateBase(notification: Notification) {
        
        if let info = notification.userInfo as? [String:AnyObject] {
            base = info["selected"] as! String
            loadData()
            currencySelector.setTitle(base, for: .normal)
            currencySelector.setImage(UIImage(named: "\(base).png"), for: .normal)
        }
        
        dimView.removeFromSuperview()
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CurrencyTableViewCell
        
        cell.flagView.image = UIImage(named: "\(countries[indexPath.row]).png")
        cell.codeView.text = countries[indexPath.row]
        cell.rateView.text = rates[indexPath.row]

        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectBase" {
            
            let baseVC = segue.destination as! BaseCurrencySelectorViewController
            baseVC.modalPresentationStyle = .custom
            baseVC.transitioningDelegate = self
            
            //dim out background view
            dimView.frame = self.view.frame
            self.view.addSubview(self.dimView)
            dimView.backgroundColor = UIColor.lightGray
            dimView.alpha = 0
            
            UIView.animate(withDuration: 0.35, animations: {
                self.dimView.alpha = 0.6
            })
            
            // add base country to the list of countries
            var completeCountries = countries
            completeCountries.append(base)
            let sorted = completeCountries.sorted { $0 < $1 }
            baseVC.countries = sorted
            baseVC.currentSelection = sorted.index(of: base)!
            
        } else if segue.identifier == "conversionCalculator" {
            
            let conversionVC = segue.destination as! CalculatorViewController
            conversionVC.title = "Currency Calculator"
            conversionVC.base = base
            if let index = tableView.indexPath(for: (sender as! UITableViewCell)) {
                conversionVC.selected = countries[index.row]
                conversionVC.selectedRate = rates[index.row]
            }
            
            let btn = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = btn
            
        }
        
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        
    }
    

}




class HalfSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView : CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
    }
    
}
