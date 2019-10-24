//
//  PostPlayerUpdate.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/1/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

enum PostPlayerUpdate {
  case update(posts: [NetworkPost])
  case append(posts: [NetworkPost])
}
