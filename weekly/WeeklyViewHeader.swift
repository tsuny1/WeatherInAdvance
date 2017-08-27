
import UIKit
class WeeklyViewHeader: UICollectionReusableView {
    
    var textLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    var headerIndex:Int = 1
    let screenWidth = UIScreen.main.bounds.width
    

    var delegate: HeaderDelegate!
    override init(frame: CGRect) {

        
        
        super.init(frame: frame)

        let saveButton: UIButton = UIButton(frame: CGRect(x: self.frame.width / 8 * 2, y: 0, width: self.frame.width / 4, height: self.frame.height  ))
        saveButton.backgroundColor = UIColor(red: 55.0/255.0, green: 230.0/255.0, blue: 67.0/255.0, alpha: 1.0)

        saveButton.setTitle("Save", for: .normal)
                saveButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        saveButton.titleLabel?.font =  UIFont(name: "Arial", size: 20)

        let deleteButton: UIButton = UIButton(frame: CGRect(x: self.frame.width / 8 * 5, y: 0, width: self.frame.width / 4, height: self.frame.height  ))
        deleteButton.backgroundColor = UIColor(red: 252.0/255.0, green: 62.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.titleLabel?.font =  UIFont(name: "Arial", size: 20)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        deleteButton.tag = 1
        self.addSubview(saveButton)
        self.addSubview(deleteButton)
        self.addSubview(textLabel)
        
        textLabel.font =  UIFont.boldSystemFont(ofSize: CGFloat(16.0))
        textLabel.textAlignment = .left
        
        
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
    func buttonAction(button:UIButton) {
        delegate.didPressButton(index: headerIndex)
    }
    func deleteButtonAction(button:UIButton) {
        delegate.handleDeleteButton(index: headerIndex)    }
}

protocol HeaderDelegate {
    func didPressButton(index:Int)
    func handleDeleteButton(index:Int)

}
