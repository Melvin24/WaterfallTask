//
//  Comment.swift
//  WaterfallTask
//
//  Created by Melvin John on 23/05/2018.
//  Copyright © 2018 Melvin. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    let id: Int
    let name: String
    let email: String
    let body: String
}
