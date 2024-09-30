//
//  ExamplePayload.swift
//  MultipeerKitExample
//
//  Created by Guilherme Rambo on 29/02/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct ExamplePayload: Hashable, Codable {
    let message: String
    let senderIP: String? // IP 주소를 추가합니다.
}

