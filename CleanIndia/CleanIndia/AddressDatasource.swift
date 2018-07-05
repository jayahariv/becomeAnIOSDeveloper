//
/*
AddressDatasource.swift
Created on: 7/5/18

Abstract:
this class will be the datasource for searchbar results. 

*/

import UIKit

class AddressDatasource: NSObject, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "cell - "
        return cell
    }
}
