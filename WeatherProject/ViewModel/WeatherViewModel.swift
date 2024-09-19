//
//  WeatherViewModel.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation
import Combine
import CoreLocation


class WeatherViewModel: NSObject, ObservableObject,CLLocationManagerDelegate {
    
    private var cancellables: [AnyCancellable] = []
    
    private var weatherService: APIServiceProtocol
    
    @Published var weatherResponse: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let locationManager = CLLocationManager()
    
    init(weatherService: APIServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
        super.init()
        locationManager.delegate = self
    }
    
    func fetchWeather(with city: String?) {
        
        guard let city = city else {
            errorMessage = "City name cannot be empty."
            return
        }
        print(city)
        let weatherService = WeatherService()
        let userDefault = UserDefaults()
        userDefault.set(city, forKey: UserDefaultKeys.lastCity.rawValue)
        isLoading = true
        let url = buildURL(city: city)
        
        weatherService.call(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.weatherResponse = response
            })
            .store(in: &cancellables)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        let url = buildURL(latitude: latitude, longitude: longitude)
        
        weatherService.call(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.weatherResponse = response
            })
            .store(in: &cancellables)
    }
    
    func buildURL(city: String? = nil, latitude: Double? = nil, longitude: Double? = nil) -> URL? {
        var url: URL?
        if let city = city, !city.isEmpty {
            url = URL(string: "\(URLConstant.baseURL.rawValue)/data/2.5/weather?q=\(city),us&APPID=\(URLConstant.weatherID.rawValue)")
        } else if let latitude = latitude, let longitude = longitude {
            url = URL(string: "\(URLConstant.baseURL.rawValue)/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&APPID=\(URLConstant.weatherID.rawValue)")
        }
        return url
    }
    
    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func loadLastCityOrLocation() {
        if let lastCity = UserDefaults.standard.string(forKey: UserDefaultKeys.lastCity.rawValue) {
            fetchWeather(with: lastCity)
        } else {
            requestLocationAccess()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
}
