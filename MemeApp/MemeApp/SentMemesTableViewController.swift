//
//  SentMemesTableViewController.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    // MARK: UI Configuration methods
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==
                MemeDetailViewController.SegueToMemeDetailViewController.fromTableView.rawValue {
            let vc = segue.destination as! MemeDetailViewController
            vc.meme = sender as! Meme
        }
    }
}

// MARK: - Table view data source

extension SentMemesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentMemesTableViewCell",
                                                 for: indexPath) as! SentMemesTableViewCell
        let meme = memes[indexPath.row]
        cell.memeImageview?.image = meme.memedImage
        cell.memeLabel.text = "\(meme.topText) \(meme.bottomText)"
        return cell
    }
}

// MARK: Table view delegate

extension SentMemesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: MemeDetailViewController.SegueToMemeDetailViewController.fromTableView.rawValue,
            sender: memes[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeMeme(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
}
