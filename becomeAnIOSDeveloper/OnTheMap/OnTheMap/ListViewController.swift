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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate struct C {
        static let title = "One the Map"
        static let tableReusableID = "listTableView"
        static let studentsLoadingError = "Students Location loading Error"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHomeNavigationBarButtons()
        setupUI()
    }
    
    // MARK: Helper methods
    
    func setupUI() {
        title = C.title
    }
    
    
    // MARK: NavigationItemsDelegate
    
    func onLogout() {
        logout()
    }
    
    func onRefresh() {

        activityIndicator.startAnimating()
        loadStudentLocations { [unowned self] (success, error) in
            
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator.stopAnimating()
            }
            
            guard error == nil && success == true else {
                switch error?.code {
                case HttpErrors.HttpErrorCode.InvalidStatusCode:
                    self.show(C.studentsLoadingError, message: Constants.Messages.serverError)
                default:
                    self.showError(C.studentsLoadingError, error: error)
                }
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
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
        return StoreConfig.shared.studentLocationResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.tableReusableID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.tableReusableID)
        }
        
        let studentLocation = StoreConfig.shared.studentLocationResults[indexPath.row]
        
        cell?.textLabel?.text = (studentLocation.firstName ?? "") + " " + (studentLocation.lastName ?? "")
        cell?.detailTextLabel?.text = studentLocation.mediaURL
        cell?.imageView?.image = UIImage(named: "icon_pin")
        
        return cell!
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = StoreConfig.shared.studentLocationResults[indexPath.row]
        
        guard let mediaURL = studentLocation.mediaURL, mediaURL.openInSafari() else {
            showAlertMessage(Constants.Messages.invalidURL)
            return
        }
    }
}
