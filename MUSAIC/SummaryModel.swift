//
//  SummaryModel.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 7/6/2023.
//

import Foundation

struct Album: Decodable {
    let URL: String
    let title: String
    let caption: String
    let shortReflection: String
    let mindRecom: String
    let mindDescRecom: String
    let goals: [String]
}
