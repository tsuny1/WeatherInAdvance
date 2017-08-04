
//
//  weeklyViewController.swift
//  weeklyWeather
//
//  Created by Will Yeung on 7/22/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import UIKit


class weeklyViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate   {
    let cellId = "WishListCell"
    var panGestureEnabled = false
    
    var myCollectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout())
    let headerId = "WishListHeaderView"
    let daysOfTheWeek = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var startTime: TimeInterval = 0.0
//    lazy var panGesture: UIPanGestureRecognizer = {
//        let pan =  UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
//            pan.delegate = self
//        return pan
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.collectionView?.register(TableCell.self, forCellWithReuseIdentifier: "TableCell")
//        self.collectionView?.backgroundColor = UIColor.blue
        
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        myCollectionView = collectionView
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "myCollectionViewCell")
        
        collectionView.register(WishListHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.cyan
        self.view.addSubview(collectionView)
        
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0))
        
   
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//              collectionView.addGestureRecognizer(panGesture)
        
        myCollectionView.isScrollEnabled = true
//        panGesture.isEnabled = panGestureEnabled

        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        myCollectionView.addGestureRecognizer(tap)

        
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer? = nil) {
        print("asdasdasdasd")

        if sender?.state == .began {
//            scrollEnabled = false
            panGestureEnabled = true
            

        }
//        if sender?.state == .began {
//            startTime = NSDate.timeIntervalSinceReferenceDate
//
//            locationOfBeganTap = sender?.location(in: self.collectionView)
//            print("locationOfBeganTap in BEGAN State -> .\(locationOfBeganTap)")
//            print("start Time -> .\(startTime)")
//
//        }
//        if sender?.state == .ended {
//            var endTime : TimeInterval = 0.0
//            endTime = NSDate.timeIntervalSinceReferenceDate
//
//            print("end Time -> .\(endTime)")
//
//        }
    }
    func handleTap(sender: UILongPressGestureRecognizer? = nil) {
      
        if sender?.state == .began {

//       scrollEnabled = false
 
            
myCollectionView.isScrollEnabled = false
            print("ASDASd")
        }
        if sender?.state == .ended {
            
            myCollectionView.isScrollEnabled = true
            var endPoint = sender?.location(in: myCollectionView)
            print(endPoint!)
    }
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
     
        return true
    }
    
 
   
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
      return  CGSize(width: view.frame.width, height: 50)
    }
    override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: headerId,
                                                                             for: indexPath) as! WishListHeaderView
            
            headerView.textLabel.text = daysOfTheWeek[indexPath.section]
            return headerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 800)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionViewCell", for: indexPath) as! CategoryCell
        cell.contentView.backgroundColor = UIColor.blue
        return cell
            }
    
    
    
}



