//
//  ViewController.swift
//  weekly
//
//  Created by Will Yeung on 7/23/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

//       let button = WeeklyButton(frame: CGRect(x: 300, y: 100, width: 100, height: 50))
//        button.setTitle("Button Title",for: .normal)
        let button = UIButton(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func pressButton(button: UIButton) {
        let layout =  UICollectionViewLayout()
        let newViewController = weeklyViewController(collectionViewLayout:layout)

        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

