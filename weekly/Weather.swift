//
//  Weather.swift
//  weekly
//
//  Created by Will Yeung on 8/25/17.
//  Copyright © 2017 Will Yeung. All rights reserved.
//

import Foundation

struct Weather {
    let shortForeCast:String
    let startHour:Int
    let startDay:Int
    let startDayOfTheWeek:Int
    let endHour:Int
    let endDay:Int
    let endDayOfTheWeek:Int
    let temperature:Int
    let percentChanceOfRain:Int
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        var percentChanceOfRain = 0
        guard let shortForeCast = json["shortForecast"] as? String else {throw SerializationError.missing("summary is missing")}
        
        if shortForeCast.lowercased().range(of:"rain") != nil || shortForeCast.lowercased().range(of:"shower") != nil  {
           percentChanceOfRain = percentChanceOfRain + 40
            
            
        } else if shortForeCast.lowercased().range(of:"drizzle") != nil  {
            percentChanceOfRain = percentChanceOfRain + 30
        }
        
        if shortForeCast.lowercased().range(of:"slight chance") != nil ||
            shortForeCast.lowercased().range(of:"patchy") != nil{
            percentChanceOfRain = percentChanceOfRain - 20
        } else if shortForeCast.lowercased().range(of:"likely") != nil  {
            percentChanceOfRain = percentChanceOfRain + 40
        }  else if shortForeCast.lowercased().range(of:"chance") != nil  {
            percentChanceOfRain = percentChanceOfRain - 10
        }

        
        
        
      
        
        guard let startTime = json["startTime"] as? String else {throw SerializationError.missing("starttime is missing")}
        guard let endTime = json["endTime"] as? String else {throw SerializationError.missing("endTime is missing")}
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let convertedDateBeginning: Date = dateFormatter.date(from: startTime)!
        let convertedDateEnd: Date = dateFormatter.date(from: endTime)!
        
        let calendar = Calendar.current
        let dayOfTheWeekBeginning = Helper.getDayOfWeek(date: convertedDateBeginning)!
        let hourBeginning = calendar.component(.hour, from: convertedDateBeginning)
        let dayBeginning = calendar.component(.day, from: convertedDateBeginning)
        
        let dayOfTheWeekEnd = Helper.getDayOfWeek(date: convertedDateEnd)!
        let hourEnd = calendar.component(.hour, from: convertedDateEnd)
        let dayEnd = calendar.component(.day, from: convertedDateEnd)
        
        
        
        
        guard let temperature = json["temperature"] as? Int else {throw SerializationError.missing("temp is missing")}
        
        
        
        self.shortForeCast = shortForeCast
        self.startHour = hourBeginning
        self.startDay = dayBeginning
        self.startDayOfTheWeek = dayOfTheWeekBeginning
        self.endHour = hourEnd
        self.endDay = dayEnd
        self.endDayOfTheWeek = dayOfTheWeekEnd
        self.temperature = temperature
        self.percentChanceOfRain = percentChanceOfRain
    }
    
    
    
    static func forecast (completion: @escaping ([Weather]) -> ()) {
        
        var url = "https://api.weather.gov/points/39.7456,-97.0892/forecast/hourly"

        let defaults = UserDefaults.standard
        if var latitude = defaults.string(forKey: "latitude") {
            if var longitude = defaults.string(forKey: "longitude") {
                latitude = String(format: "%.4f", Double(latitude)!)
                longitude = String(format: "%.4f", Double(longitude)!)

                 url = "https://api.weather.gov/points/" + latitude + "," + longitude + "/forecast/hourly"
                
            }
        }
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["properties"] as? [String:Any] {
                            if let dailyData = dailyForecasts["periods"] as? [[String:Any]]  {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        if(weatherObject.startHour >= 8 && weatherObject.endHour <= 23
                                            && weatherObject.percentChanceOfRain >= -1000){
                                            forecastArray.append(weatherObject)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        task.resume()
        
        
    }
    
    
}
