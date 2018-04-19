//
//  SentMemesCollectionViewController.swift
//  MemeApp
//
//  Created by Jayahari Vavachan on 4/18/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

private let reuseIdentifier = "sentMemesCollectionViewCell"

class SentMemesCollectionViewController: UICollectionViewController {

    // MARK: UI Config methods
    
    func setupUI() {
        self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==
            MemeDetailViewController.SegueToMemeDetailViewController.fromCollectionView.rawValue {
            let vc = segue.destination as! MemeDetailViewController
            vc.meme = sender as! Meme
        }
    }
}

// MARK: UICollectionViewDataSource

extension SentMemesCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! SentMemesCollectionViewCell
        let meme = memes[indexPath.row]
        cell.memeImageView.image = meme.memedImage
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension SentMemesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: MemeDetailViewController.SegueToMemeDetailViewController.fromCollectionView.rawValue,
            sender: memes[indexPath.row])
    }
}
