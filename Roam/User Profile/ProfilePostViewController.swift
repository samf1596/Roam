//
//  ProfilePostViewController.swift
//  Roam
//
//  Created by Samuel Fox on 1/3/19.
//  Copyright © 2019 sof5207. All rights reserved.
//

import UIKit

class ProfilePostViewController: UIViewController {

    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Array((post?.locations.keys)!)[0]
        // Do any additional setup after loading the view.
    }
    
    func configure(_ post: Post) {
        self.post = post
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
