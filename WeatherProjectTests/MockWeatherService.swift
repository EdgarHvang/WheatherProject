//
//  MockWeatherService.swift
//  WeatherProjectTests
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation
import Combine
@testable import WeatherProject

class MockAPIService: APIServiceProtocol {
    var queue: DispatchQueue = DispatchQueue.main
    
    var shouldReturnError = false
    var mockData: Data?
    var error: Error = URLError(.badServerResponse)
    
    func call<T: Decodable>(from endpoint: URL?) -> AnyPublisher<T, Error> where T: Decodable {
        if shouldReturnError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        guard let data = mockData else {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
        return Just(data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: queue)
            .mapError { error in
                error as Error
            }
            .eraseToAnyPublisher()
    }
}


