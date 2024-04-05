//
//  Models.swift
//  weatherAPI
//
//  Created by Jawwad Abbasi on 2024-04-04.
//
import SwiftUI
import Foundation


struct Weather: Codable {
    var location: Location
    var forecast: Forecast
}

struct Location: Codable {
    var name: String
}

struct Forecast: Codable {
    var forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var date_epoch: Int
    var id: Int { date_epoch }
    var hour: [Hour]
    var day: Day
}

struct Day: Codable {
    var avgtemp_c: Double
    var condition: Condition
}

struct Condition: Codable {
    var text: String
    var code: Int
}

struct Hour: Codable, Identifiable{
    var time_epoch: Int
    var time: String
    var temp_c:Double
    var condition: Condition
    var id: Int{time_epoch}
}
