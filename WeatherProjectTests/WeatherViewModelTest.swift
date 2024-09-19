//
//  WeatherViewModelTest.swift
//  WeatherProjectTests
//
//  Created by Qiyao Huang on 9/18/24.
//

import XCTest
import Combine
@testable import WeatherProject

final class WeatherViewModelTest: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
    }
    
    override func tearDown() {
        mockAPIService = nil
        cancellables = []
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() {
        let weatherResponse = WeatherResponse(
            coord: Coord(lon: -96.7969, lat: 32.7767),  // Coordinates for Dallas
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            base: "stations",
            main: Main(temp: 20.0, feels_like: 18.0, temp_min: 18.0, temp_max: 22.0, pressure: 1012, humidity: 60, sea_level: nil, grnd_level: nil),
            visibility: 10000,
            wind: Wind(speed: 3.0, deg: 200, gust: nil),
            clouds: Clouds(all: 0),
            dt: 1608446400,
            sys: Sys(type: 1, id: 1001, country: "US", sunrise: 1608410400, sunset: 1608446400),
            timezone: -21600,  // Dallas timezone offset
            id: 0,  // ID is not as important in this context
            name: "Dallas",
            cod: 200
        )
        
        let encoder = JSONEncoder()
        mockAPIService.mockData = try! encoder.encode(weatherResponse)
        
        let expectation = XCTestExpectation(description: "Fetch weather successfully")
        
        mockAPIService.call(from: URL(string: "https://api.mockservice.com"))
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected successful response, got \(error) instead.")
                }
            }, receiveValue: { (response: WeatherResponse) in
                XCTAssertEqual(response.name, "Dallas")
                XCTAssertEqual(response.main.temp, 20.0)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchWeatherFailure() {
        mockAPIService.shouldReturnError = true
        
        let expectation = XCTestExpectation(description: "Handle error response")
        
        mockAPIService.call(from: URL(string: "https://api.mockservice.com"))
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure but got success.")
                }
            }, receiveValue: { (response: WeatherResponse) in
                XCTFail("Expected failure, but got response \(response) instead.")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
