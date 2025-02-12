//
//  HomeImage.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import Foundation

// MARK: - HomeImage
struct HomeImage: Decodable, Identifiable {
    var id: String?
    var urls: Urls?

    enum CodingKeys: String, CodingKey {
        case id
        case urls
    }
}


// MARK: - Urls
struct Urls: Decodable {
    var raw, full, regular, small: String?
    var thumb: String?
}
