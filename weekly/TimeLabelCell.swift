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
        

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    
    func setupViews(){
        backgroundColor = UIColor.brown
        let selectionView = UIView()
        self.selectedBackgroundView = selectionView
        
        self.addSubview(timeLabel)
        
        addContraintsWithFormat("H:|-8-[v0]-8-|", views: timeLabel,  viewItself: self)
        addContraintsWithFormat("V:|[v0]|", views: timeLabel, viewItself: self)
    }
}
