import UIKit
class TimeLabelCell: UICollectionViewCell {
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "header"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        
    }
    
//        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            if let touch = touches.first {
//                print("started touc")
//            }
//        }
//    
    func addContraintsWithFormat(_ format: String, views: UIView...) {
        var viewDict = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDict[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.brown
        let selectionView = UIView()
        
        selectionView.backgroundColor = UIColor.black
        self.selectedBackgroundView = selectionView
        
        self.addSubview(timeLabel)
        
        addContraintsWithFormat("H:|-8-[v0]-8-|", views: timeLabel)
        addContraintsWithFormat("V:|[v0]|", views: timeLabel)
    }
}
