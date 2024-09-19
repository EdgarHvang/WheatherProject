//
//  WeatherService.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation
import Combine

class WeatherService: APIServiceProtocol {
    
    var queue: DispatchQueue = DispatchQueue.main
    
    func call<T>(from url: URL?) -> AnyPublisher<T, any Error> where T : Decodable {
        guard let url = url else {
            return Fail(error: NetWorkError.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                
                guard let code = (output.response as? HTTPURLResponse)?.statusCode else {
                    throw NetWorkError.unexpectedResponse
                }
                guard HTTPCodes.success.contains(code) else {
                    throw NetWorkError.statusCodeError(code)
                }
                return output.data
            }.decode(type: T.self, decoder: JSONDecoder())
            .mapError({ _ in
                NetWorkError.parseJsonFailed
            })
            .receive(on: queue)
            .eraseToAnyPublisher()
    } 
}
