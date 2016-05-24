//
//  ViewController.swift
//  Neuralisator
//
//  Created by Danny Lin on 2016/5/11.
//  Copyright © 2016年 DL. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var neuralisator: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func initialize() {
        setupNeuralisator()
    }

    func setupNeuralisator() {
        neuralisator.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.eraseMemory))
        tapGestureRecognizer.delegate = self

        neuralisator.addGestureRecognizer(tapGestureRecognizer)
    }

    func eraseMemory() {
        performSegueWithIdentifier("eraseMemory", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

