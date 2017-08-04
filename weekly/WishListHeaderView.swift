
import UIKit
class WishListHeaderView: UICollectionReusableView {
    
    var textLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    
    let screenWidth = UIScreen.main.bounds.width
    
    override init(frame: CGRect) {

        
        
        super.init(frame: frame)

        let saveButton: UIButton = UIButton(frame: CGRect(x: 80, y: 10, width: 80, height: 40))
        saveButton.backgroundColor = UIColor.green
        saveButton.setTitle("Save", for: .normal)
        //        btn.addTarget(self, action: #selector(buttonAction), forControlEvents: .touchUpInside)
        saveButton.tag = 1
        
        let deleteButton: UIButton = UIButton(frame: CGRect(x: 180, y: 10, width: 80, height: 40))
        deleteButton.backgroundColor = UIColor.red
        deleteButton.setTitle("Delete", for: .normal)
        //        btn.addTarget(self, action: #selector(buttonAction), forControlEvents: .touchUpInside)
        
        deleteButton.tag = 1
        self.addSubview(saveButton)
        self.addSubview(deleteButton)
        self.addSubview(textLabel)
        
        textLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        textLabel.textAlignment = .left
        textLabel.numberOfLines = 0
        
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal,
                               toItem: self, attribute: .leadingMargin,
                               multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal,
                               toItem: self, attribute: .trailingMargin,
                               multiplier: 1.0, constant: 0.0),
            ])
        
        self.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
