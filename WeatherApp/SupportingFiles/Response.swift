//
//  Response.swift
//  WeatherApp
//
//  Created by Андрей Цуркан on 11.10.2023.
//

import Foundation

struct Response: Codable {
    var location: Location
    var current: Current
    var forecast: Forecast
}

struct Location: Codable {
    var name: String
}

struct Current: Codable {
    var temp: Double?
    var condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp_c"
        case condition = "condition"
    }
}

struct Condition: Codable {
    var text: String?
    var icon: String?
}

struct Forecast: Codable {
    var forecastday: [Forecastday]
}

struct Forecastday: Codable {
    var day: Day
    var hour: [Hour]?
    var date: String?
    var dateEpoch: Int?
    
    enum CodingKeys: String, CodingKey {
        case day = "day"
        case dateEpoch = "date_epoch"
        case hour = "hour"
        case date = "date"
    }
    
    struct Day: Codable {
        var maxTemp: Double?
        var mintemp: Double?
        var condition: Condition
        
        enum CodingKeys: String, CodingKey {
            case maxTemp = "maxtemp_c"
            case mintemp = "mintemp_c"
            case condition = "condition"
        }
    }
    
    struct Hour: Codable {
        var time: String?
        var temp: Double?
        
        enum CodingKeys: String, CodingKey {
            case time = "time"
            case temp = "temp_c"
        }
    }
}
