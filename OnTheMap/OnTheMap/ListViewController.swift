//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jayahari Vavachan on 5/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, Alerting, HomeNavigationItemsProtocol {
    
    // MARK: Properties
    
    // IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // Class Properties
    var studentLocationResults: StudentLocationResults?
    
    fileprivate struct C {
        static let title = "One the Map"
        static let tableReusableID = "listTableView"
        static let invalidURLErrorMessage = "Please enter a valid URL"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        getStudentLocations()
        setupUI()
    }
    
    // MARK: Helper methods
    
    func setupUI() {
        title = C.title
    }
    
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
    
    // MARK: NavigationItemsDelegate
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {
        getStudentLocations()
    }
    
    func onAddPin() {
        addLocationPin()
    }
    
    func onCancel() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocationResults?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.tableReusableID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.tableReusableID)
        }
        
        let studentLocation = studentLocationResults?.results[indexPath.row]
        
        cell?.textLabel?.text = (studentLocation?.firstName ?? "") + " " + (studentLocation?.lastName ?? "")
        cell?.detailTextLabel?.text = studentLocation?.mediaURL
        cell?.imageView?.image = UIImage(named: "icon_pin")
        
        return cell!
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentLocationResults?.results[indexPath.row]
        
        guard let mediaURL = studentLocation?.mediaURL, mediaURL.openInSafari() else {
            showAlertMessage(C.invalidURLErrorMessage)
            return
        }
    }
}
