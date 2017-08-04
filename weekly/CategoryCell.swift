import UIKit

class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
    private let timeLabelCell = "timeLabelCell"
    private let infoCell = "infoCell"
    let timeArray = ["8:00 AM","9:00 AM","10:00 AM","11:00 AM","12:00 AM",
                     "12:00 PM","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM","6:00 PM","7:00 PM",
                     "8:00 PM", "9:00 PM"]
    var counter = 0;
    
    var arrayOfBoolean = [Bool](repeating: true, count: 90)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let appsCollectionView: UICollectionView = {
        let layout = weeklyLayout()
        
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        let screenHeight = screenSize.height
//        print(screenSize)
//        print(screenWidth)
//        print(screenHeight)
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.red
        return collectionView
    }()
    
    func setupViews() {
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(CategoryCell.handleTap(sender:)))
//        pan.delegate = self
//        
//        self.addGestureRecognizer(tap)
        
        addSubview(appsCollectionView)
        
        appsCollectionView.delegate = self
        appsCollectionView.dataSource = self
        appsCollectionView.register(TimeLabelCell.self, forCellWithReuseIdentifier: timeLabelCell)
        appsCollectionView.register(InfoCell.self, forCellWithReuseIdentifier: infoCell)
        appsCollectionView.allowsMultipleSelection = true
        appsCollectionView.allowsSelection = true
        addContraintsWithFormat("H:|-8-[v0]-8-|", views: appsCollectionView)
        addContraintsWithFormat("V:|[v0]|", views: appsCollectionView)
        arrayOfBoolean[30] = true
    }
    

   
    func handleTap(sender: UITapGestureRecognizer? = nil) {
            }
    func addContraintsWithFormat(_ format: String, views: UIView...) {
        var viewDict = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDict[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            print("started touc")
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeArray.count  + timeArray.count *  4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row   < 15 {
            let leftCell = collectionView.dequeueReusableCell(withReuseIdentifier: timeLabelCell, for: indexPath) as! TimeLabelCell
            leftCell.timeLabel.text = timeArray[indexPath.row]
            return leftCell
            
        }
        
        let rightCell = collectionView.dequeueReusableCell(withReuseIdentifier: infoCell, for: indexPath) as! InfoCell

        return rightCell
    }
    
}

class weeklyLayout: UICollectionViewLayout {
    
    // 2
    var numberOfColumns = 2
    
    // 3
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // 4
    private var contentHeight: CGFloat  = 100
    private var contentWidth: CGFloat {
        let insets = collectionView!.bounds.width
        return insets
    }
    
    

    override func prepare() {
        // 1
        if cache.isEmpty {
            // 2
            let columnWidth = contentWidth / CGFloat(numberOfColumns)  - 1
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            // 3
//            print(xOffset)
            
            
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                
                column = (item > 16) ? 1 : 0
            
                let indexPath = IndexPath(item: item, section: 0)
                // 4
                
                var height : CGFloat = 0.0
                if column == 0 {
                
                 height = collectionView!.bounds.height / 15
                }
                else {
                     height = collectionView!.bounds.height / 60

                }
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)

                let insetFrame = frame.insetBy(dx: 0.0, dy: 0.0)
                
                // 5
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                

            
            }
            
            
            
            
        }
//        print(cache)
    }
    
    
    override var collectionViewContentSize: CGSize {
        let collection = collectionView!
        let width = collection.bounds.size.width
        let height = collection.bounds.size.width
        return CGSize(width: width, height: height)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var count = 0
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                count = count + 1
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { attributes -> Bool in
            return attributes.indexPath == indexPath
        }
    }
}
