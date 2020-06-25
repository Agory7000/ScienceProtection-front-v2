//
//  CheckHash.swift
//  IOSTakePhoto
//
//  Created by Дмитрий Симеониди on 25.06.2020.
//  Copyright © 2020 Moonlight. All rights reserved.
//

import UIKit

class CheckHash : UIViewController, UINavigationControllerDelegate {
    var userName : String?
    
    @IBAction func PhotoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toPhoto_2", sender: self)
    }
    
    @IBAction func VideoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toVideo_2", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto_2" {
            guard let destination = segue.destination as? TakePhoto_2 else {return}
            destination.userName = userName
        } else if segue.identifier == "toVideo_2" {
            //
            // переход на экран с видео
            //
        } else {
            return
        }
    }
}
