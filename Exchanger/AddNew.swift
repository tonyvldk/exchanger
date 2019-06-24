//
//  AddNew.swift
//  Exchanger
//
//  Created by Anton on 6/24/19.
//  Copyright © 2019 YAD.agency. All rights reserved.
//

import UIKit
import RealmSwift
import NotificationBannerSwift

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
}

class AddNew: UITableViewController {
    
    let realm = try! Realm()
    var currenciesList: Results<Currencies>!
    var currencyNumber = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currenciesList = realm.objects(Currencies.self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currenciesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addNewCurrencyCell", for: indexPath)
            as! CurrencyCell

        cell.codeLabel?.text = currenciesList[indexPath.row].currencyCode
        cell.nameLabel?.text = currenciesList[indexPath.row].currencyName

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currencyNumber == 1 {
            let firstCurrency = favCurrencies()
            firstCurrency.firstCurrencyCode = currenciesList[indexPath.row].currencyCode
            firstCurrency.firstCurrencyName = currenciesList[indexPath.row].currencyName
            
            try! realm.write {
                realm.add(firstCurrency)
            }

            currencyNumber = 2
            self.title = "Second currency"
            
            let banner = StatusBarNotificationBanner(title: "First currency successfully added", style: .success)
            banner.duration = 0.3
            banner.show()
        } else {
            let secondCurrency = realm.objects(favCurrencies.self).last
            try! realm.write {
                secondCurrency!.secondCurrencyCode = currenciesList[indexPath.row].currencyCode
                secondCurrency!.secondCurrencyName = currenciesList[indexPath.row].currencyName
            }
            
            let banner = StatusBarNotificationBanner(title: "Second currency successfully added", style: .success)
            banner.duration = 0.3
            banner.show()
            
            currencyNumber = 3
            
            navigationController?.popToRootViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            if currencyNumber != 3 {
               let currencyToDelete = realm.objects(favCurrencies.self).last
                
                try! realm.write {
                    realm.delete(currencyToDelete!)
                }
            }
        }
    }
}
