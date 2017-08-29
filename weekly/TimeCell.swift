import UIKit
class TimeCell: UICollectionViewCell {
    

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
    func addLabel (name:String, location: String){
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        label.textAlignment = .center
        
        label.text = name + "\t Location: " + location
        
        self.addSubview(label)
        
    }
    func removeLabel() {
        for subview in self.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
  
 
    func setupViews(){
        backgroundColor = UIColor.white
        let selectionView = UIView()
        
        selectionView.backgroundColor = UIColor.yellow
        self.selectedBackgroundView = selectionView
        
      
        addContraintsWithFormat("H:|[v0]|", views: selectionView, viewItself: self)
       addContraintsWithFormat("V:|[v0]|", views: selectionView, viewItself: self)
    }
}
