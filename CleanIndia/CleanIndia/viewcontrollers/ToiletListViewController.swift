//
/*
ToiletListViewController.swift
Created on: 7/12/18

Abstract:
 this will show all the saved toilets in the form of table

*/

import UIKit
import Firebase

final class ToiletListViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private var db: Firestore!
    private var toilets = [[String: Any]]()
    
    /// File Constants are declared inside this struct
    private struct C {
        static let cell = "toiletCell"
    }
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchToilets()
        
    }
    
    // MARK: Button Actions
    
    @IBAction func onMap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Private Helper methods

private extension ToiletListViewController {
    
    /**
     fetches all the toilets from firestore, populates the iVar `toilets`, and reloads the `tableView`
     - note: If fails, prints the error details in console.
     */
    func fetchToilets() {
        db = Firestore.firestore()
        db.collection(Constants.Firestore.Keys.TOILETS).getDocuments() { [unowned self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                var data = [[String: Any]]()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    data.append(document.data())
                }
                self.toilets = data
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: ToiletListViewController -> UITableViewDataSource

extension ToiletListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toilets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.cell) as? CIToiletTableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: C.cell) as? CIToiletTableViewCell
        }
        
        let toilet = toilets[indexPath.row]
        if let name = toilet[Constants.Firestore.Keys.NAME] as? String {
            cell?.titleLabel.text = name
        }
        
        if let address = toilet[Constants.Firestore.Keys.ADDRESS] as? String {
            cell?.subtitleLabel.text = address
        }
        
        if let rating = toilet[Constants.Firestore.Keys.RATING] as? Int {
            cell?.cleanIndicator.isOn = rating >= 3
        }
        
        return cell!
    }
}
