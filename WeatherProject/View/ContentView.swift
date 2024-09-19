//
//  ContentView.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = WeatherViewModel()
    @State private var cityName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter US City", text: $cityName, onCommit: {
                        viewModel.fetchWeather(with: cityName)
                        self.cityName = cityName
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    Button(action: {
                        viewModel.fetchWeather(with: cityName)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, 16)
                    }
                }
                if let weather = viewModel.weatherResponse {
                    VStack {
                        Text("Weather in \(weather.name)")
                            .font(.largeTitle)
                            .padding(.top)
                        
                        if let icon = weather.weather.first?.icon {
                            WeatherIconView(icon: icon)
                        }
                        
                        Text("Temperature: \(weather.main.temp, specifier: "%.1f")°C")
                        Text("Feels like: \(weather.main.feels_like, specifier: "%.1f")°C")
                        Text("Humidity: \(weather.main.humidity)%")
                        Text("Wind Speed: \(weather.wind.speed, specifier: "%.1f") m/s")
                    }
                    .padding()
                } else if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Weather App")
            .onAppear {
                viewModel.loadLastCityOrLocation()
            }
        }.onAppear {
            viewModel.requestLocationAccess()
        }
    }
}

#Preview {
    ContentView()
}
