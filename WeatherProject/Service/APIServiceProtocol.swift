//
//  ClientProtocol.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    var queue: DispatchQueue {get}
    func call<T: Decodable>(from endpoint: URL?) -> AnyPublisher<T, Error> where T: Decodable
}
