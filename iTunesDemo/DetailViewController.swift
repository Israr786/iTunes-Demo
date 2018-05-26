//
//  DetailViewController.swift
//  iTunesDemo
//
//  Created by Apple on 5/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel?
    @IBOutlet weak var trackId: UILabel?
    @IBOutlet weak var collectionPrice: UILabel?
    @IBOutlet weak var collectionName: UILabel?
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var trackName: UILabel?
    var imageDownloaded : UIImage?
    var appDetailObject = Apps()

   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
      //  navigationController?.navigationBar.isHidden = false
        navigationItem.title = appDetailObject.artistName
         configureView()
        
    }
    
    // configure the view
    func configureView() {
        //TODO
        detailDescriptionLabel?.text = appDetailObject.artistName
        trackId?.text = String(describing: appDetailObject.trackId)
        collectionName?.text = appDetailObject.wrapperType
        trackName?.text = appDetailObject.trackName
        collectionPrice?.text = String(describing:  appDetailObject.collectionPrice)
        
        // calling download on background thread
        DispatchQueue.global().async {
            self.setupImagePreview()
        }
        
    }
    
    
    // downlaoding artWork to display
    func setupImagePreview(){
        let url = URL(string: appDetailObject.artworkUrl!)
        URLSession.shared.dataTask(with: url!) { (imageData, response, error) in
            if error != nil {
                print(error)
            }
            self.imageDownloaded = UIImage(data: imageData!)
            
            //Updating UI after download
            DispatchQueue.main.async {
                self.previewImageView?.image = self.imageDownloaded
                self.previewImageView?.contentMode = .scaleAspectFit
            }
            }.resume()
        
    }
    
    //Play buttom handle method
    @IBAction func handlePlayButton(_ sender: Any) {
        let songUrl = URL(string:self.appDetailObject.previewUrl!)
        let player = AVPlayer(url: songUrl!)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        player.play()
        present(playerVC, animated: true, completion: nil)
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view. //TODO
          // configureView()
        }
    }
    
    
  

}

