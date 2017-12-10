//
//  ViewController.swift
//  Cainreaction
//
//  Created by TørK on 05/12/2017.
//  Copyright © 2017 Tørk Egeberg. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor.black, for: .normal)
        view.addSubview(resetButton)
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

