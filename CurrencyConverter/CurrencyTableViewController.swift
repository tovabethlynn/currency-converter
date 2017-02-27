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
    var loadDate = ""
    
    let dimView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        currencySelector.setTitle(base, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBase(notification:)), name: NSNotification.Name(rawValue: "updateBase"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closedCalculator), name: NSNotification.Name(rawValue: "closeCalc"), object: nil)
        
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
                if let date = json["date"] as? String {
                    self.loadDate = date
                }
                
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
    
    
    func closedCalculator() {
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
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
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.lightGray
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Rates valid from \(loadDate)"
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
        
        //dim out background view
        dimView.frame = self.view.frame
        self.view.addSubview(self.dimView)
        dimView.backgroundColor = UIColor.lightGray
        dimView.alpha = 0
        
        UIView.animate(withDuration: 0.35, animations: {
            self.dimView.alpha = 0.6
        })
        
        if segue.identifier == "selectBase" {
            
            let baseVC = segue.destination as! BaseCurrencySelectorViewController
            baseVC.modalPresentationStyle = .custom
            baseVC.transitioningDelegate = self
            
            // add base country to the list of countries
            var completeCountries = countries
            completeCountries.append(base)
            let sorted = completeCountries.sorted { $0 < $1 }
            baseVC.countries = sorted
            baseVC.currentSelection = sorted.index(of: base)!
            
        } else if segue.identifier == "conversionCalculator" {
            
            let conversionVC = segue.destination as! CalculatorViewController
            conversionVC.modalPresentationStyle = .custom
            conversionVC.transitioningDelegate = self
            
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
        if let _ = presented as? BaseCurrencySelectorViewController {
            return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
        } else {
            return ThreeQuarterSizePresentationController(presentedViewController: presented, presenting: presenting)
        }
        
    }
    

}




class HalfSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView : CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
    }
    
}




class ThreeQuarterSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView : CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height / 4, width: containerView!.bounds.width, height: containerView!.bounds.height * 3/4)
    }
    
}
