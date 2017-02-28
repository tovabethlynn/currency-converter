//
//  CurrencyTableViewController.swift
//  CurrencyConverter
//
//  Created by Tova Grobert on 2/22/17.
//  Copyright © 2017 Toes. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class CurrencyTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var currencySelector: UIButton!

    var base = "USD"
    var countries = [String]()
    var rates = [String]()
    var loadDate: String?
    
    let dimView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        activityIndicator.activityIndicatorViewStyle = .white
        activityIndicator.backgroundColor = UIColor(red:0x50/255, green:0x50/255, blue:0x50/255, alpha: 0.5)
        activityIndicator.layer.cornerRadius = 10
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        loadData()
        
        currencySelector.setTitle(base, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBase(notification:)), name: NSNotification.Name(rawValue: "updateBase"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closedCalculator), name: NSNotification.Name(rawValue: "closeCalc"), object: nil)
        
    }
    
    
    func loadData() {
        
        // clear the table (for refreshing or changing base)
        countries.removeAll()
        rates.removeAll()
        loadDate = nil
        tableView.reloadData()
        
        // retrieve the data
        let urlString = "https://api.fixer.io/latest?base=\(base)"
        
        Alamofire.request(urlString)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    guard let json = value as? [String: Any],
                        let date = json["date"] as? String,
                        let rates = json["rates"] as? [String:Any] else {
                            self.displayAlert()
                            return
                    }
                    
                    self.loadDate = date
                    
                    let countryList = rates.keys
                    self.countries = countryList.sorted { $0 < $1 }

                    self.rates = self.countries.map({ (country) -> String in
                        var formattedRate = NumberFormatter.localizedString(from: rates[country] as! NSNumber, number: .currency)
                        formattedRate.remove(at: formattedRate.startIndex)  // remove dollar sign
                        return formattedRate
                    })

                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayAlert()
                }
                
            self.tableView.refreshControl?.endRefreshing()
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    
    func displayAlert() {
                
        let alert = UIAlertController(title: "Error", message: "There was an error loading the data. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
        self.present(alert, animated: false, completion: nil)
        
    }
    
    
    func updateBase(notification: Notification) {
        
        if let info = notification.userInfo as? [String:AnyObject] {
            base = info["selected"] as! String
            currencySelector.setTitle(base, for: .normal)
            currencySelector.setImage(UIImage(named: "\(base).png"), for: .normal)
            activityIndicator.startAnimating()
            loadData()
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
        if loadDate != nil {
            return "Rates valid from \(loadDate!)"
        } else {
            return nil
        }
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
