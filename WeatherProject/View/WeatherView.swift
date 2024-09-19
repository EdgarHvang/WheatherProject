//
//  WeatherView.swift
//  WeatherProject
//
//  Created by Qiyao Huang on 9/18/24.
//

import Foundation
import SwiftUI

struct WeatherIconView: View {
    let icon: String
    
    var body: some View {
        let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        
        AsyncImage(url: URL(string: iconURL)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            } else if phase.error != nil {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
        }
    }
}
