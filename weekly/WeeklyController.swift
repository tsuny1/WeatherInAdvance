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
    var previousSection = -1
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
//    /Users/WillY/weekly/weekly/WeeklyController.swift:106:89: 'NSGregorianCalendar' was deprecated in iOS 8.0: Use NSCalendarIdentifierGregorian instead
    func getDayOfWeek(date: Date)->Int? {
        let myCalendar = NSCalendar.current
        let myComponents = myCalendar.dateComponents([.day,.month,.year,.weekday], from: Date())
        let weekDay = myComponents.weekday
        return weekDay
    }
    
        func setUpTable(){
             self.calendars = eventStore.calendars(for: EKEntityType.event)
            let oneMonthAgo = Date()
            let oneMonthAfter = NSDate(timeIntervalSinceNow: +4*24*3600)
            do{
                   let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
//                let p1 = NSPredicate(format: "beginningTimeHour == %d", 8)
//                let p2 = NSPredicate(format: "endTimeHour == %d", 11)
//
//                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
//                fetchRequest.predicate = predicate

                let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
//
//
//                
                
                                for result in searchResults as [SlotEntity]{
                    let dayOfTheWeek = Int(result.dayOfTheWeek)
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

            for calendar in calendars! {
                
                
                    let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
                    
                    let events = eventStore.events(matching: predicate)
                    
                    for event in events {
                        
                        let dayOfTheWeek = getDayOfWeek(date: event.startDate)! as Int - 1
                        let title = event.title
                        let location = event.location
                        let beginningHour = Calendar.current.component(.hour, from: event.startDate)
                        let beginningMinute = Calendar.current.component(.minute, from: event.startDate)
                      let endingHour = Calendar.current.component(.hour, from: event.endDate)
 let endingMinute = Calendar.current.component(.minute, from: event.endDate)
                      
                        var newOne = Slots(name: title, location: location!, beginningTimeHour: beginningHour, beginningTimeMinute:beginningMinute, endingTimeHour: endingHour, endingTimeMinute: endingMinute, dayOfTheWeek:dayOfTheWeek)
                        
                                let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
//
//                        
//                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
//                        
//                         do {
//                           let result = try DatabaseController.getContext().execute(deleteRequest)
//                        } catch {
//                            
//                        }
                        
                        
             
//                        weeklySlots[dayOfTheWeek].addTime(newTime:newOne )
                        
                }
                
                
            }
    
        }
    func updateCoreData(){
        let slotEntityClassName:String = String(describing: SlotEntity.self)
        let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()
        
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
//
//        
        DatabaseController.saveContext()
        
//        let p1 = NSPredicate(format: "beginningTimeHour = %@", 8)
//        let p2 = NSPredicate(format: "endingTimeHour = %@", 10)
//
//        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
//        
        
//        fetchRequest.predicate = predicate
        
       do{
            let fetchResults = try DatabaseController.getContext().fetch(fetchRequest)
                print(fetchResults.count)
        
            
        }
        catch{
        }

           }

    func handleDeleteButton(index: Int) {
        for index in 0 ..< weeklySlots.count {
            for j in 0 ..< weeklySlots[index].schedule.count {
                if(weeklySlots[index].schedule[j].selected){
                    let startingIndex = Helper.convertTimeToIndex(numberOfSlots: timeArray.count * 4, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: weeklySlots[index].schedule[j].beginningTimeHour, timeMinute: weeklySlots[index].schedule[j].beginningTimeMinute, offset: timeArray.count)
                    let endingIndex = Helper.convertTimeToIndex(numberOfSlots: timeArray.count * 4, startingHour: 8, numberOfIntervalsInHour: 4, timeHour: weeklySlots[index].schedule[j].endingTimeHour, timeMinute: weeklySlots[index].schedule[j].endingTimeMinute, offset: timeArray.count)
                   let newArray =  Helper.deletePreviousSection(array: arrayOfChecked, section: index, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                    arrayOfChecked = newArray
                    
                    weeklySlots[index].schedule.remove(at: j)
                    let slotEntityClassName:String = String(describing: SlotEntity.self)
                    let fetchRequest:NSFetchRequest<SlotEntity> = SlotEntity.fetchRequest()

                    let startingTimeHourConverted = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: startingIndex, offset: self.timeArray.count)
                    let endTimeHourConverted = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: endingIndex, offset: self.timeArray.count)
                    
                    let p1 = NSPredicate(format: "beginningTimeHour == %d", startingTimeHourConverted)
                    let p2 = NSPredicate(format: "endTimeHour == %d", endTimeHourConverted)
                    
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                    fetchRequest.predicate = predicate
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
                    do {
                     try DatabaseController.getContext().execute(deleteRequest)

                    }
                    catch {
                        
                    }
                }
            }
            
        }
        myCollectionView.reloadData()
    }
    
    func didPressButton(index:Int) {
        
//        weeklySlots[0].addTime(newTime: Slots(name: "asd", location: "asdasd", beginningTimeHour: 10, beginningTimeMinute: 15, endingTimeHour: 11, endingTimeMinute: 30))
//        myCollectionView.reloadData()
        let ac : UIAlertController = {
            let alertController = UIAlertController( title: "Edit Device Name", message: "Enter a new nickname for your device:", preferredStyle: .alert)
            alertController.addTextField(configurationHandler: {
                (textField: UITextField) in
                textField.placeholder = "Name"
            })
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Location"
            }
            let saveAction = UIAlertAction(title:"Save", style: .default, handler: {
                action in
                let nameField = alertController.textFields!.first!.text!
                let locationField = alertController.textFields![1].text!
                let startingTimeHour = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.startingIndex, offset: self.timeArray.count)
                let startingTimeMinute = Helper.convertIndexToTimeMinute(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.startingIndex, offset: self.timeArray.count)
                let endingTimeHour = Helper.convertIndexToTimeHour(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.endingIndex  + 1, offset: self.timeArray.count)
                 let endingTimeMinute = Helper.convertIndexToTimeMinute(numberOfSlots: 60, startingHour: 8, numberOfIntervalsInHour: 4, index: self.endingIndex  + 1, offset: self.timeArray.count)
                
                self.weeklySlots[self.previousSection].addTime(newTime: Slots(name: nameField, location: locationField, beginningTimeHour: startingTimeHour, beginningTimeMinute: startingTimeMinute, endingTimeHour: endingTimeHour, endingTimeMinute: endingTimeMinute, dayOfTheWeek: self.previousSection))

                self.setPartialState()
                
                self.updateCoreData()
                self.myCollectionView.reloadData()
                
                
                
            })
            alertController.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: { action in }))
            
            alertController.addAction(saveAction)
            return alertController
        }()
        myCollectionView.reloadData()
        self.present(ac, animated: true)
    }
    
    func setPartialState() {
        self.startingIndex  =  -1
        self.endingIndex = -1
        self.previousSection = -1
        self.deletePrevious = false
    }
    
    func handleTap(sender: UILongPressGestureRecognizer? = nil) {
        let whichCell = sender?.location(in:myCollectionView)
        if let currentCellIndex =  myCollectionView.indexPathForItem(at: (whichCell)!){
            
            if let currentCell = myCollectionView.cellForItem(at: currentCellIndex) as! CategoryCell? {
                var nestedIndex = currentCell.getPositionInCell(point: (sender?.location(in: currentCell.appsCollectionView))!)
                let section = currentCellIndex[0]
                let nestedIndexUnwrapped = nestedIndex[1] - timeArray.count
                
                
                if(sender?.state == .began) {
                    if(deletePrevious){
                        arrayOfChecked =   Helper.deletePreviousSection(array: arrayOfChecked, section: section, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
                        self.setPartialState()
                    }
                    if(arrayOfChecked[section][nestedIndexUnwrapped]) {
                        validStartingPosition = false
                    } else {                        
                        validStartingPosition = true
                    }
                    if(validStartingPosition) {
                        myCollectionView.isScrollEnabled = false
                        myCollectionView.reloadData()
                        currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                        startingIndex = nestedIndexUnwrapped + timeArray.count
                        previousSection = section
                                         }
                    
                }
                if(sender?.state == .changed && validStartingPosition) {
                    currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    if(nestedIndexUnwrapped + timeArray.count + 1 < 60) {
                        currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count + 1)
                    }
                }
                
                if(sender?.state == .ended && validStartingPosition) {
                    
                    currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    endingIndex = Int(nestedIndexUnwrapped) + timeArray.count
                    arrayOfChecked =  Helper.setSectionToTrue(array: arrayOfChecked, section : section, startingI: startingIndex, endingI: endingIndex, offset: timeArray.count)
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
                if(!arrayOfChecked[currentSection][nestedIndexUnwrapped]) {
                    arrayOfChecked[currentSection][nestedIndexUnwrapped] = true
                    currentCell.changeCellSelection(index: nestedIndexUnwrapped + timeArray.count)
                    startingIndex =  nestedIndexUnwrapped + timeArray.count
                    endingIndex = startingIndex
                    deletePrevious = true
                    previousSection = currentSection
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
        return  CGSize(width: view.frame.width, height: view.frame.height / 16)
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



