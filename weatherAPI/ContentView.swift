//
//  ContentView.swift
//  weatherAPI
//
//  Created by Jawwad Abbasi on 2024-03-31.
//

import SwiftUI
import Alamofire

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
    var day: Day
}

struct Day: Codable {
    var avgtemp_c: Double
    var condition: Condition
}

struct Condition: Codable {
    var text: String
}

struct ContentView: View {
    
    let blueSky = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    
    let greySky = Color.init(red: 47/255, green: 79/255, blue: 79/255)
    
    @State private var results = [ForecastDay] ()
    @State var backgroundColor = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly Overcast"
    @State var cityName = "Toronto"
    @State var loading = true
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("\(cityName)")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .bold()
            
            Text("\(Date().formatted(date: .complete, time: .omitted))")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            
            Text(weatherEmoji)
                .font(.system(size: 200))
                .shadow(radius: 50)
            
            Text("\(currentTemp)°C")
                .foregroundStyle(.white)
                .font(.system(size: 50))
                .bold()
            
            Text("\(conditionText)")
                .foregroundStyle(.white)
                .font(.system(size: 25))
                .bold()
            
            Spacer()
            Spacer()
            Spacer()
            
            List(results) { forecast in
                
                HStack(alignment: .center, spacing: nil) {
                    
                    Text("\(getShortDate(epoch: forecast.date_epoch))")
                        .frame(maxWidth: 50, alignment: .leading)
                        .bold()
                    
                    Text("\(getWeatherEmoji(text: forecast.day.condition.text))")
                        .frame(maxWidth: 30, alignment: .leading)
                    
                    Text("\(Int(forecast.day.avgtemp_c))°C")
                        .frame(maxWidth: 50, alignment: .leading)
                    
                    Spacer()
                    
                    Text("\(forecast.day.condition.text)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.white.blur(radius: 75).opacity(0.5))
            }
            .contentMargins(.vertical, 0)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            
            Spacer()
            
            Text("Data Supplied By Weather API")
                .foregroundStyle(.white)
                .font(.title3)
            
        }
        .background(backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await fetchWeather()
        }
    }
    
    func fetchWeather() async {
        let request = AF.request("http://api.weatherapi.com/v1/forecast.json?key=06addee7535a4582982190340243103&q=Pickering&days=3&aqi=no&alerts=no")
        
        request.responseDecodable(of: Weather.self) { response in
            switch response.result {
            case.success(let weather):
                dump(weather)
                cityName = weather.location.name
                results = weather.forecast.forecastday
                currentTemp = Int(results[0].day.avgtemp_c)
                backgroundColor = getBackgroundColor(text: results[0].day.condition.text)
                weatherEmoji = getWeatherEmoji(text: results[0].day.condition.text)
                loading = false
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func getWeatherEmoji(text: String) -> String {
        var weatherEmoji = "☀️"
        
        let conditionText = text.lowercased()
        
        if conditionText.contains("snow") || conditionText.contains("blizzard") {
            weatherEmoji = "🌨️"
        } else if conditionText.contains("rain") {
            weatherEmoji = "🌧️"
        } else if conditionText.contains("partly cloudy") {
            weatherEmoji = "🌤️"
        } else if conditionText.contains("cloudy") || conditionText.contains("overcast") {
            weatherEmoji = "☁️"
        } else if conditionText.contains("clear") || conditionText.contains("sunny") {
            weatherEmoji = "☀️"
        }
        return weatherEmoji
    }
    
    func getBackgroundColor(text: String) -> Color {
        
        var backgroundColor = blueSky
        
        let conditionText = text.lowercased()
        
        if !(conditionText.contains("clear") || conditionText.contains("sunny")) {
            backgroundColor = greySky
        }
        return backgroundColor
    }
    
    func getShortDate(epoch: Int) -> String {
        
        return Date(timeIntervalSince1970: TimeInterval(epoch)).formatted(Date.FormatStyle().weekday(.abbreviated))
    }
    
}

#Preview {
    ContentView()
}
