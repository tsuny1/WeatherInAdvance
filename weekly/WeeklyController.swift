
import UIKit
import EventKit
import CoreData

class weeklyViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate, HeaderDelegate   {
    let timeArray = ["8:00 AM","9:00 AM","10:00 AM","11:00 AM",
                     "12:00 PM","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM","6:00 PM","7:00 PM",
                     "8:00 PM", "9:00 PM", "10:00 PM"]
    
    var myCollectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout())
    let daysOfTheWeek = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    var startTime: TimeInterval = 0.0
    var startingIndex = -1
    var endingIndex = -1
    var beginningSection = -1
    var endSection = -1
    var deletePrevious = false
    var validStartingPosition = true
    var arrayOfChecked = [[Bool]] ()
    var weeklySlots =  [DailyTimes]()
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpWeeklySlots()
        arrayOfChecked = Array(repeating: Array(repeating: false, count: timeArray.count * 4), count: daysOfTheWeek.count)
        myCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        myCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "myCollectionViewCell")
        myCollectionView.register(WeeklyViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "WishListHeaderView")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = UIColor.white
        (myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
        
        self.view.addSubview(myCollectionView)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        myCollectionView.addGestureRecognizer(tap)
        myCollectionView.frame = CGRect(x: 0 ,y: 0, width: self.view.frame.width, height: self.view.frame.height - 64)
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.handleTouch(sender:)))
        touch.delegate = self
        myCollectionView.addGestureRecognizer(touch)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkCalendarAuthorizationStatus()
    }
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.authorized:
            setUpTable()
            
            break
            // Things are in line with being able to show the calendars in the table view
            
        default: break
            
        }
    }
    func isSaveButtonDisabled() -> Bool {
        if(startingIndex == -1 || endingIndex == -1) {
            return true
        }
        return false
    }
    
    
    func getDayOfWeek(date: Date) -> Int? {
        let myCalendar = NSCalendar.current
        let myComponents = myCalendar.dateComponents([.day,.month,.year,.weekday], from: Date())
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    func setUpTable(){
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        do{
            let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
      
            
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
       
            for result in searchResults as [SlotEntity]{
                let dayOfTheWeek = Int(result.dayOfTheWeek) % 7
                let beginningTimeHour = Int(result.beginningTimeHour)
                let beginningTimeMinute = Int(result.beginningTimeMinute)
                let endTimeHour = Int(result.endTimeHour)
                let endTimeMinute = Int(result.endTimeMinute)
                let name = result.name
                let location = result.location
             
                let newBlock = Slots(name: name!, location: location!, beginningTimeHour: beginningTimeHour, beginningTimeMinute:beginningTimeMinute, endingTimeHour: endTimeHour, endingTimeMinute: endTimeMinute, dayOfTheWeek:dayOfTheWeek)
                weeklySlots[dayOfTheWeek].addTime(newTime: newBlock)
            }
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    func updateCoreData(){
        let slotEntityClassName:String = String(describing: SlotEntity.self)
        
        for i in 0 ..< weeklySlots.count {
            for j in 0 ..< weeklySlots[i].schedule.count {
                
                
                let currentBlock = weeklySlots[i].schedule[j]
                let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
                
                let p1 = NSPredicate(format: "beginningTimeHour == %d", currentBlock.beginningTimeHour)
                let p2 = NSPredicate(format: "endTimeHour == %d", currentBlock.endingTimeHour)
                
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                fetchRequest.predicate = predicate
                do {
                    let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                    if fetchResults.count == 0 {
                        let sampleSlotEntity = NSEntityDescription.insertNewObject(forEntityName: slotEntityClassName, into: DatabaseController.getContext()) as! SlotEntity
                        
                        sampleSlotEntity.beginningTimeHour = Int16(currentBlock.beginningTimeHour)
                        sampleSlotEntity.beginningTimeMinute = Int16(currentBlock.beginningTimeMinute)
                        
                        sampleSlotEntity.endTimeHour = Int16(currentBlock.endingTimeHour)
                        sampleSlotEntity.endTimeMinute = Int16(currentBlock.endingTimeMinute)
                        sampleSlotEntity.dayOfTheWeek = Int16(currentBlock.dayOfTheWeek)
                        sampleSlotEntity.name = currentBlock.name
                        sampleSlotEntity.location = currentBlock.location
                    }
                    
                } catch {
                    
                }
                
                
            }
        }
        
        DatabaseController.saveContext()
    }
    
    func handleDeleteButton(index: Int) {
        for index in 0 ..< weeklySlots.count {
            for j in 0 ..< weeklySlots[index].schedule.count {
                if(weeklySlots[index].schedule[j].selected){
            
                    let startingIndex = Helper.convertTimeToIndex(numberOfSlots: timeArray.count * 4, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: weeklySlots[index].schedule[j].beginningTimeHour, timeMinute: weeklySlots[index].schedule[j].beginningTimeMinute, offset: timeArray.count)
                    let endingIndex = Helper.convertTimeToIndex(numberOfSlots: timeArray.count * 4, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: weeklySlots[index].schedule[j].endingTimeHour, timeMinute: weeklySlots[index].schedule[j].endingTimeMinute, offset: timeArray.count)
                    arrayOfChecked =  Helper.deletePreviousSection(array: arrayOfChecked, section: index, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                    let currentBlock = weeklySlots[index].schedule[j]
                    weeklySlots[index].schedule.remove(at: j)
                    let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
      
                    let p1 = NSPredicate(format: "beginningTimeHour == %d", currentBlock.beginningTimeHour)
                    let p2 = NSPredicate(format: "endTimeHour == %d", currentBlock.endingTimeHour)
                    
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                    fetchRequest.predicate = predicate
                    
                    let context = DatabaseController.getContext()
                  
                    do {
                        let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                        for object in fetchResults {
                            context.delete(object)
                        }
                    }
                    catch
                    {
                    }
                  
                    DatabaseController.saveContext()
                    myCollectionView.reloadData()

                    return
                }
            }
            
        }
    }
    
    func didPressButton(index:Int) {
        if isSaveButtonDisabled() == false {
            let ac : UIAlertController = {
                let alertController = UIAlertController( title: "Edit Device Name", message: "Enter a new nickname for your device:", preferredStyle: .alert)

                let saveAction = UIAlertAction(title:"Save", style: .default, handler: {
                    action in
            
                    let nameField = alertController.textFields!.first!.text!
                    let locationField = alertController.textFields![1].text!
                    let startingTimeHour = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.startingIndex, offset: self.timeArray.count)
                    let startingTimeMinute = Helper.convertIndexToTimeMinute(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.startingIndex, offset: self.timeArray.count)
                    let endingTimeHour = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.endingIndex, offset: self.timeArray.count)
                    let endingTimeMinute = Helper.convertIndexToTimeMinute(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.endingIndex, offset: self.timeArray.count)
                    
                        self.weeklySlots[self.beginningSection].addTime(newTime: Slots(name: nameField, location: locationField, beginningTimeHour: startingTimeHour, beginningTimeMinute: startingTimeMinute, endingTimeHour: endingTimeHour, endingTimeMinute: endingTimeMinute, dayOfTheWeek: self.beginningSection))
                        print("asdasd")
                        self.setPartialState()
                        self.updateCoreData()
                        self.myCollectionView.reloadData()

                })
                saveAction.isEnabled = false
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Enter something"
               
                })
                
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Enter something different"
                    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                        saveAction.isEnabled = alertController.textFields!.first!.text!.characters.count > 0 && alertController.textFields![1].text!.characters.count > 0
                    }
                })
            
           
                alertController.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: { action in }))
            
                alertController.addAction(saveAction)
                
                return alertController
            }()
            myCollectionView.reloadData()
            self.present(ac, animated: true)
        }
    }
    
    func setPartialState() {
        self.startingIndex  =  -1
        self.endingIndex = -1
        self.beginningSection = -1
        self.endSection = -1
        self.deletePrevious = false
    }
    
    func checkIfIndexIsAlreadyHighlighted(endIndex:Int, dayOfTheWeek:Int) -> Bool {
        for i in 0 ..< weeklySlots[dayOfTheWeek].schedule.count {
            let currentSlot = weeklySlots[dayOfTheWeek].schedule[i]
            let convertedCurrentBeginningIndex = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: currentSlot.beginningTimeHour , timeMinute:  currentSlot.beginningTimeMinute,offset: 15)
            let convertedCurrentEndIndex = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: currentSlot.endingTimeHour , timeMinute:  currentSlot.beginningTimeMinute,offset: 15)
            if(endIndex >= convertedCurrentBeginningIndex && endIndex <= convertedCurrentEndIndex){
                return true
            }
            
        }
        return false
    }
    func handleTap(sender: UILongPressGestureRecognizer? = nil) {
        let whichCell = sender?.location(in:myCollectionView)
        if let currentCellIndex =  myCollectionView.indexPathForItem(at: (whichCell)!){
            
            if let currentCell = myCollectionView.cellForItem(at: currentCellIndex) as! CategoryCell? {
                var nestedIndex = currentCell.getPositionInCell(point: (sender?.location(in: currentCell.appsCollectionView))!)
                let section = currentCellIndex[0]
                let nestedIndexUnwrapped = nestedIndex[1] - timeArray.count
                
                
                if(sender?.state == .began ) {
                    if(deletePrevious){
                        arrayOfChecked =   Helper.deletePreviousSection(array: arrayOfChecked, section: section, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                        self.setPartialState()
                    }
                    if(nestedIndexUnwrapped < 0 || arrayOfChecked[section][nestedIndexUnwrapped]) {
                        validStartingPosition = false
                    } else {
                        validStartingPosition = true
                    }
                    if(validStartingPosition) {
                        myCollectionView.isScrollEnabled = false
                        myCollectionView.reloadData()
                        currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                        startingIndex = nestedIndexUnwrapped + timeArray.count
                        beginningSection = section
                    }
                    
                }
                if(sender?.state == .changed && validStartingPosition) {
                    currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    if(nestedIndexUnwrapped + timeArray.count + 1 < 60) {
                        currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count + 1)
                    }
                }
                
                if(sender?.state == .ended && validStartingPosition) {
                    
                    
                    
                    endingIndex = Int(nestedIndexUnwrapped) + timeArray.count
                    if(checkIfIndexIsAlreadyHighlighted(endIndex: Int(nestedIndexUnwrapped) + timeArray.count, dayOfTheWeek: beginningSection) || section != beginningSection) {
                        arrayOfChecked = Helper.deletePreviousSection(array: arrayOfChecked, section: beginningSection, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                        
                    } else {
                        arrayOfChecked =  Helper.setSectionToTrue(array: arrayOfChecked, section : section, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                        currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    }
                    
                    myCollectionView.isScrollEnabled = true
                    myCollectionView.reloadData()
                    deletePrevious = true
                } else if(sender?.state == .ended) {
                    validStartingPosition = true
                }
            }
        }
        
        
    }
    
    
    
    func handleTouch(sender: UITapGestureRecognizer? = nil) {
        let whichCell = sender?.location(in:myCollectionView)
        
        if let currentCellIndex =  myCollectionView.indexPathForItem(at: (whichCell)!){
            
            if let currentCell = myCollectionView.cellForItem(at: currentCellIndex) as! CategoryCell? {
                var nestedIndex = currentCell.getPositionInCell(point: (sender?.location(in: currentCell.appsCollectionView))!)
                let currentSection = currentCellIndex[0]
                let nestedIndexUnwrapped = nestedIndex[1] - timeArray.count
                if(deletePrevious){
                    arrayOfChecked =   Helper.deletePreviousSection(array: arrayOfChecked, section: currentSection, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                    
                    myCollectionView.reloadData()
                    
                    self.setPartialState()
                }
                if(nestedIndexUnwrapped > 0 && !arrayOfChecked[currentSection][nestedIndexUnwrapped]) {
                    arrayOfChecked[currentSection][nestedIndexUnwrapped] = true
                    currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    startingIndex =  nestedIndexUnwrapped + timeArray.count
                    endingIndex = startingIndex
                    deletePrevious = true
                    beginningSection = currentSection
                } else {
                    
                    
                }
                
                
                
                highLightColorCell(section: currentSection, index: nestedIndexUnwrapped, array: weeklySlots)
                myCollectionView.reloadData()
                
                
                
                
            }
        }
        
    }
    
    
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    func highLightColorCell(section:Int, index:Int, array: [DailyTimes]){
        for i in 0 ..< array.count {
            if(i == section){
                for j in 0 ..< array[section].schedule.count {
                    let beginningIndex = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: array[section].schedule[j].beginningTimeHour,timeMinute: array[section].schedule[j].beginningTimeMinute, offset: timeArray.count) - timeArray.count
                    let endingIndex = Helper.convertTimeToIndex(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: array[section].schedule[j].endingTimeHour, timeMinute: array[section].schedule[j].endingTimeMinute, offset: timeArray.count) - timeArray.count
                    
                    if(index >= beginningIndex && index <= endingIndex) {
                        array[section].schedule[j].selected = true
                    } else {
                        array[section].schedule[j].selected = false
                    }
                }
            }
            else {
                for k in 0 ..< array[i].schedule.count {
                    
                    array[i].schedule[k].selected = false
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return  CGSize(width: view.frame.width, height: view.frame.height/16)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WishListHeaderView",
                                                                         for: indexPath) as! WeeklyViewHeader
        
        headerView.textLabel.text = daysOfTheWeek[indexPath.section]
        headerView.headerIndex = indexPath.section
        headerView.delegate = self
        return headerView
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setUpWeeklySlots(){
        for index in 0 ..< 7 {
            weeklySlots.append(DailyTimes(dayOfTheWeek: index))
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 800)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionViewCell", for: indexPath) as! CategoryCell
        cell.arrayOfBoolean = arrayOfChecked[indexPath.section]
        cell.currentSchedule = weeklySlots[indexPath.section]
        cell.appsCollectionView.reloadData()
        return cell
    }
    
}



