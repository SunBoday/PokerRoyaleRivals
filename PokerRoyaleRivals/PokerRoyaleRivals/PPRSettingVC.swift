//
//  PPRSettingVC.swift
//  PokerRoyaleRivals
//
//  Created by SunTory on 2024/9/27.
//

import UIKit

class PPRSettingVC: UIViewController {

    //MARK: - Declare IBOutlets
    @IBOutlet weak var imgAbout: UIImageView!
    @IBOutlet weak var imgPrivacy: UIImageView!
    @IBOutlet weak var imgReview: UIImageView!
    
    
    //MARK: - Declare Variables
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        imgAbout.image = UIImage.gifImageWithName("ic_about")
        imgPrivacy.image = UIImage.gifImageWithName("ic_privacy")
        imgReview.image = UIImage.gifImageWithName("ic_feedback")
    }
    
    //MARK: - Functions
    
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Datasource and Delegate Methods
