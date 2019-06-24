//
//  Home.swift
//  Exchanger
//
//  Created by Anton on 6/24/19.
//  Copyright © 2019 YAD.agency. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class FavCell: UITableViewCell {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstCodeLabel: UILabel!
    @IBOutlet weak var secondPriceLabel: UILabel!
    @IBOutlet weak var secondInfoLabel: UILabel!
}

class Home: UITableViewController {
    
    var favCurrenciesList: Results<favCurrencies>!
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        favCurrenciesList = realm.objects(favCurrencies.self)
        tableView.reloadData()
        loadRates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadRates), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl

        let isInitialDataLoaded = UserDefaults.standard.bool(forKey: "isInitialDataLoaded")
        if (!isInitialDataLoaded) {
            initialLoad()
        }
    }

    @objc func loadRates() {
        var index: Int = 0
        
        for object in favCurrenciesList {
            Alamofire.request("https://api.exchangeratesapi.io/latest?base=\(object.firstCurrencyCode)&symbols=\(object.secondCurrencyCode)").validate().responseJSON { response in
                    switch response.result {
                        case .success:
                            if let json = response.data {
                                do {
                                    let resultDict = try JSON(data: json)
                                    let rates = resultDict["rates"]["\(object.secondCurrencyCode)"]
                                    
                                    print("\(rates)")
                                    
                                    try! self.realm.write {
                                        for currency in self.realm.objects(favCurrencies.self).filter("firstCurrencyCode = '\(object.firstCurrencyCode)' AND secondCurrencyCode = '\(object.secondCurrencyCode)'") {
                                            currency.rate = "\(rates)"
                                        }
                                    }
                                    
                                    self.tableView.reloadData()
                                } catch{
                                    print("JSON Error")
                                }
                        }
                    case .failure(let error):
                        print(error)
                }
            }
            
            index += 1;
            
            if (index == favCurrenciesList.count) {
                tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func initialLoad() {
        let currencyDict = ["AUD":"Australian dollar",
                            "BGN":"Bulgarian lev",
                            "BRL":"Brazilian real",
                            "CAD":"Canadian dollar",
                            "CHF":"Swiss franc",
                            "CNY":"Renminbi (Chinese) yuan",
                            "CZK":"Czech koruna",
                            "DKK":"Danish krone",
                            "EUR":"Euro",
                            "GBP":"Pound sterling",
                            "HKD":"Hong Kong dollar",
                            "HRK":"Croatian kuna",
                            "HUF":"Hungarian forint",
                            "IDR":"Indonesian rupiah",
                            "ILS":"Israeli new shekel",
                            "INR":"Indian rupee",
                            "ISK":"Icelandic króna",
                            "JPY":"Japanese yen",
                            "KRW":"South Korean won",
                            "MAD":"Moroccan dirham",
                            "MXN":"Mexican peso",
                            "MYR":"Malaysian ringgit",
                            "NOK":"Norwegian krone",
                            "NZD":"New Zealand dollar",
                            "PHP":"Philippine peso",
                            "PLN":"Polish złoty",
                            "RON":"Romanian leu",
                            "RUB":"Russian ruble",
                            "SEK":"Swedish krona",
                            "SGD":"Singapore dollar",
                            "THB":"Thai baht",
                            "USD":"United States dollar",
                            "ZAR":"South African rand"]

        for (key, value) in currencyDict {
            let currency = Currencies()
            currency.currencyCode = key
            currency.currencyName = value
            
            try! realm.write {
                realm.add(currency)
            }
        }
        
        UserDefaults.standard.set(true, forKey: "isInitialDataLoaded")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favCurrenciesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath)
            as! FavCell
        cell.firstCodeLabel?.text = "1 \(favCurrenciesList[indexPath.row].firstCurrencyCode)"
        cell.firstNameLabel?.text = favCurrenciesList[indexPath.row].firstCurrencyName
        cell.secondInfoLabel?.text = "\(favCurrenciesList[indexPath.row].secondCurrencyName) • \(favCurrenciesList[indexPath.row].secondCurrencyCode)"
        cell.secondPriceLabel?.text = favCurrenciesList[indexPath.row].rate

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let currencyToDelete = realm.objects(favCurrencies.self)[indexPath.row]

            try! realm.write {
                realm.delete(currencyToDelete)
            }
            
            tableView.reloadData()
        }
    }
}
