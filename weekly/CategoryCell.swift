import UIKit

class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate, WeeklyLayoutDelegate {
    
    let timeArray = ["8:00 AM","9:00 AM","10:00 AM","11:00 AM",
                     "12:00 PM","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM","6:00 PM","7:00 PM",
                     "8:00 PM", "9:00 PM", "10:00 PM"]
    
    var currentSchedule : DailyTimes = DailyTimes(dayOfTheWeek: 0)
    
    var arrayOfBoolean = [Bool]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let appsCollectionView: UICollectionView = {
        let layout = weeklyLayout()
        
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.red
        return collectionView
    }()
    
    
    func setupViews() {
        
        addSubview(appsCollectionView)
        
        appsCollectionView.delegate = self
        appsCollectionView.dataSource = self
        appsCollectionView.register(LabelCell.self, forCellWithReuseIdentifier: "LabelCell")
        appsCollectionView.register(TimeCell.self, forCellWithReuseIdentifier: "TimeCell")
        appsCollectionView.allowsMultipleSelection = false
        appsCollectionView.backgroundColor = UIColor.gray
        addContraintsWithFormat("H:|[v0]|", views: appsCollectionView, viewItself: self)
        addContraintsWithFormat("V:|[v0]|", views: appsCollectionView, viewItself: self)
        
        if let layout = appsCollectionView.collectionViewLayout as? weeklyLayout {
            layout.delegate = self
        }
    }
    
    func addContraintsWithFormat(_ format: String, views: UIView..., viewItself: UIView) {
        var viewDict = [String: UIView]()
        let viewsCopy = views
        for (index, view) in viewsCopy.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDict[key] = view
        }
        
        viewItself.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }
    
    func changeCellSelection(index: Int) {
        appsCollectionView.cellForItem(at: IndexPath(row: index, section:0))?.isSelected = true
    }
    
    func getPositionInCell (point: CGPoint) -> IndexPath{
        return appsCollectionView.indexPathForItem(at: point)!
    }
   
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
    }
    func numberOfRows() -> Int {
        return timeArray.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeArray.count + (4 * timeArray.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row < timeArray.count){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.timeLabel.text = timeArray[indexPath.row]
            return cell
        }
         let rightCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCell
       rightCell.removeLabel()
        rightCell.isSelected = arrayOfBoolean[indexPath.row - timeArray.count]

        for index in 0 ..< currentSchedule.schedule.count{
            let current = currentSchedule.schedule[index]
          
            let convertedBeginning = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: current.beginningTimeHour , timeMinute:  current.beginningTimeMinute,offset: 15)
            let convertedEnd = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: current.endingTimeHour, timeMinute:  current.endingTimeMinute , offset: 15)
            if(indexPath.row == convertedBeginning) {
                rightCell.addLabel(name: current.name, location: current.location)
            }
            
            if(indexPath.row >= convertedBeginning && indexPath.row <= convertedEnd && current.selected) {
                let newView = UIView()
                newView.backgroundColor = UIColor.green
                rightCell.selectedBackgroundView = newView
                rightCell.isSelected = true
            } else if(indexPath.row >= convertedBeginning && indexPath.row <= convertedEnd){
                let newView = UIView()
                newView.backgroundColor = UIColor.yellow
                 rightCell.selectedBackgroundView = newView
                rightCell.isSelected = true

            }

        }

        
        return rightCell
    }
    
}

protocol WeeklyLayoutDelegate {
    func numberOfRows() -> Int
}

