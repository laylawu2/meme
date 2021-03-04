//
//  MemeTableViewController.swift
//  meme
//
//  Created by layla wu on 12/3/20.
//  Copyright © 2020 layla wu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeTableViewCell"

class MemeTableViewController: UIViewController {
    
    var memes: [Meme]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    @IBOutlet weak var memesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createMeme))
        navigationItem.title = Constants.sentMemeNavbarTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memesTableView.reloadData()
    }
    
    @objc func createMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createMemeVC = storyboard.instantiateViewController(withIdentifier: "CreateMemeVC")
        show(createMemeVC, sender: self)
    }
}

extension MemeTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MemeTableViewCell
        cell.memeImageView?.image = memes[indexPath.row].memedImage
        cell.memeTextLabel?.text = "\(memes[indexPath.row].topText), \(memes[indexPath.row].bottomText)".uppercased()
        return cell
    }
    
    
}
