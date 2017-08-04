import UIKit
class InfoCell: UICollectionViewCell {
    
   var isChosen: Bool = false
  override   init(frame: CGRect) {
        
        super.init(frame: frame)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        label.textAlignment = .center
        label.text = "I'am a test label"
        self.addSubview(label)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        setupViews()

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setChosenToBeTrue() {
        self.isChosen = true
    }
    
    func setupViews(){

        print(isChosen)

        backgroundColor = UIColor.gray
        
//        backgroundColor = UIColor.green
    
}
}
