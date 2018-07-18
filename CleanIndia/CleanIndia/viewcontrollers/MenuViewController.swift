//
/*
MenuViewController.swift
Created on: 7/18/18

Abstract:
TODO: Purpose of file

*/

import UIKit

class MenuViewController: UIViewController {
    private var menuLabels: [String] = ["Government Data", "Login"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "menuTableCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "menuTableCell")
        }
        cell?.textLabel?.text = menuLabels[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc: UIViewController!
        switch indexPath.row {
        case 0:
            // goverment data
            vc = storyboard?.instantiateViewController(withIdentifier: "GovernmentDataViewController")
        case 1:
            vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            // login/logout
        default:
            break
        }
        navigationController?.show(vc, sender: nil)
    }
}
