//
//  MemeDetailViewController.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    /*
     MARK: Segues to MemeDetailViewController
        List down all the segues to this view controller.
     */
    
    enum SegueToMemeDetailViewController: String {
        case fromTableView = "memeTableViewToDetailView";
        case fromCollectionView = "memeCollectionViewToDetailView";
    }
    
    // MARK: UI Config methods
    
    func setupUI() {
        imageView.image = meme.memedImage
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}
