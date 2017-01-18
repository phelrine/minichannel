//
//  MoviePlayerViewController.swift
//  minichannel
//
//  Created by nagasaka.shogo on 1/19/17.
//  Copyright © 2017 jp.ne.donuts. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class MoviePlayerViewController: UIViewController {

    var controller: AVPlayerViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        controller?.view.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: self.view.bounds.size.width, height: self.view.bounds.size.width);
        super.viewDidLayoutSubviews()
    }

    func loadMovie(_ url: URL) {
        let player = AVPlayer(url: url)
        controller = AVPlayerViewController()
        controller?.player = player
        self.addChildViewController(controller!)
        self.view.addSubview(controller!.view)
        player.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
