//
//  StartingScene.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 13.04.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit

class StartingScene: UIViewController, UINavigationControllerDelegate {
    
    var userName : String?
    
    @IBAction func photoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toPhotoView", sender: self)
    }
    
    @IBAction func videoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toVideoView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoView" {
            guard let destination = segue.destination as? TakePhoto else {return}
            destination.userName = userName
        } else if segue.identifier == "toVideoView" {
            //
            // переход на экран с видео
            //
        } else {
            return
        }
    }
}
