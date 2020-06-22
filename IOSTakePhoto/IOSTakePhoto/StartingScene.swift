//
//  StartingScene.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 13.04.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit

class StartingScene: UIViewController, UINavigationControllerDelegate {
    @IBAction func photoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toPhotoView", sender: self)
    }
    
    @IBAction func videoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toVideoView", sender: self)
    }
    
    @IBAction func audioTapped(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
