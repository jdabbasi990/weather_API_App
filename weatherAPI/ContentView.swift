//
//  ContentView.swift
//  weatherAPI
//
//  Created by Jawwad Abbasi on 2024-03-31.
//

import SwiftUI
import Alamofire


struct ContentView: View {
    
    
    @State private var results = [ForecastDay] ()
    @State var hourlyForcast = [Hour]()
    @State var query: String = ""
    @State var contentSize: CGSize = .zero
    @State var textFieldHeight = 15.0
    @State var backgroundColor = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly Overcast"
    @State var cityName = "Toronto"
    @State var loading = true
    
    var body: some View {
        if loading {
            ZStack{
                Color.init(backgroundColor)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        await fetchWeather(query: "")
                    }
            }
            
        }else{
            NavigationView{

            VStack {
                    Spacer()
                    TextField("Enter city name or postal code",text: $query, onEditingChanged: getFocus)
                        .textFieldStyle(PlainTextFieldStyle())
                        .background(
                            Rectangle()
                                .foregroundColor(.white.opacity(0.2))
                                .cornerRadius(25)
                                .frame(height: 50)
                        )
                        .padding(.leading, 40)
                        .padding(.trailing, 40)
                        .padding(.bottom, 15)
                        .padding(.top, textFieldHeight)
                        .multilineTextAlignment(.center)
                        .accentColor(.white)
                        .font(Font.system(size: 20, design: .default))
                        .onSubmit {
                            Task{
                                await fetchWeather(query:query)
                            }
                            withAnimation{
                                textFieldHeight = 15
                            }
                        }
                    
                    Text("\(cityName)")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                        .bold()
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                        .padding(.bottom,1)
                    
                    Text("\(Date().formatted(date: .complete, time: .omitted))")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                    
                    
                    Text(weatherEmoji)
                        .font(.system(size: 110))
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                    
                    Text("\(currentTemp)°C")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                    
                    Text("\(conditionText)")
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("Hourly Forcast")
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                        .bold()
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer()
                            ForEach(hourlyForcast) { forecast in
                                VStack{
                                    Text("\(getShortTime(time: forecast.time))")
                                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                                    Text("\(getWeatherEmoji(code: forecast.condition.code))")
                                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                                    Text("\(Int(forecast.temp_c)) C")
                                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                                }
                                .frame(width: 50, height: 90)
                            }
                            Spacer()
                        }
                        .background(Color.white.blur(radius: 75).opacity(0.35))
                        .cornerRadius(15)
                    }
                    .padding(.top, .zero)
                    .padding(.leading, 18)
                    .padding(.trailing,18)
                    Spacer()
                    
                    
                    Text("3 Day Forecast")
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                        .bold()
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                        .padding(.top,12)
                    
                    List {
                        ForEach(Array(results.enumerated()), id: \.1.id) { index,  forecast in
                            
                        NavigationLink{
                            WeatherDetails(results: $results, cityName: $cityName, index: index)
                            
                        } label:{
                            
                            HStack(alignment: .center, spacing: nil) {
                                
                                Text("\(getShortDate(epoch: forecast.date_epoch))")
                                    .frame(maxWidth: 50, alignment: .leading)
                                    .bold()
                                
                                Text("\(getWeatherEmoji(code: forecast.day.condition.code))")
                                    .frame(maxWidth: 30, alignment: .leading)
                                
                                Text("\(Int(forecast.day.avgtemp_c))°C")
                                    .frame(maxWidth: 50, alignment: .leading)
                                
                                Spacer()
                                
                                Text("\(forecast.day.condition.text)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.2), radius: 1, x: 0, y: 2)
                                
                            }
                          }
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
                    await fetchWeather(query: "")
                }
            }
            .accentColor(.white)

             
        }
    }
    
    func getFocus(focused: Bool){
        withAnimation{
            (textFieldHeight = 130)
        }
    }
    
    func fetchWeather(query: String ) async {
        var queryText = ""
        
        if (query == ""){
            queryText = "http://api.weatherapi.com/v1/forecast.json?key=06addee7535a4582982190340243103&q=Pickering&days=3&aqi=no&alerts=no"
        }else {
            queryText = "http://api.weatherapi.com/v1/forecast.json?key=06addee7535a4582982190340243103&q=\(query)&days=3&aqi=no&alerts=no"
        }
        let request = AF.request(queryText)
        
        request.responseDecodable(of: Weather.self) { response in
            switch response.result {
            case.success(let weather):
//                dump(weather)
                cityName = weather.location.name
                results = weather.forecast.forecastday
                var index = 0
                if Date (timeIntervalSince1970: TimeInterval(results[0].date_epoch)).formatted(Date.FormatStyle().weekday(.abbreviated)) != Date().formatted(Date.FormatStyle().weekday(.abbreviated)) {
                    
                    index = 1
                    
                }
                currentTemp = Int(results[0].day.avgtemp_c)
                hourlyForcast = results[index].hour

                backgroundColor = getBackgroundColor(code: results[0].day.condition.code)
                weatherEmoji = getWeatherEmoji(code: results[0].day.condition.code)
                conditionText = results[index].day.condition.text
                loading = false
                
            case.failure(let error):
                print(error)
            }
        }
    }
}
    
    #Preview {
        ContentView()
    }

