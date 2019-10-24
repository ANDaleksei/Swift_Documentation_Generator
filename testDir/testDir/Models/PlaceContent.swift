//
//  PlaceContent.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 4/22/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

struct PlaceContent: Equatable {

  let posts: [NetworkPost]
  let tags: [PlaceTag]

  init(posts: [NetworkPost], tags: [PlaceTag]) {
    self.posts = posts
    self.tags = tags
  }
}
