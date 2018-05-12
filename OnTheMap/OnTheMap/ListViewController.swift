//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var studentLocationResults: StudentLocationResults?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        getStudentLocations()
    }
    
    // MARK: Helper methods
    
    func getStudentLocations() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            HttpClient.shared.getStudentLocation(1,
                                                 pageCount: 100,
                                                 sort: StudentLocationSortOrder.inverseUpdatedAt)
            { [unowned self] (result, error) in
                
                guard error == nil else {
                    return
                }
                
                self.studentLocationResults = result
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Navigation Items Delegate methods
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        getStudentLocations()
    }
    
    func onAddPin() {
        addLocationPin()
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocationResults?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "listTableView"
        var cell = tableView.dequeueReusableCell(withIdentifier: id)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: id)
        }
        
        let studentLocation = studentLocationResults?.results[indexPath.row]
        
        cell?.textLabel?.text = (studentLocation?.firstName ?? "") + " " + (studentLocation?.lastName ?? "")
        cell?.detailTextLabel?.text = studentLocation?.mediaURL
        cell?.imageView?.image = UIImage(named: "icon_pin")
        
        return cell!
    }
}
