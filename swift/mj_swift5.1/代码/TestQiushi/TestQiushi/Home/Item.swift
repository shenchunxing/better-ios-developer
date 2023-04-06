//
//  Item.swift
//  Qiushibaike
//
//  Created by MJ Lee on 2019/8/10.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

struct Item: Convertible {
    let content: String = ""
    let commentsCount: Int = 0
    let lowUrl: String = ""
    let highUrl: String = ""
    let originUrl: String = ""
    let publishedAt: Int = 0
    let user: User! = nil
    let hotComment: Comment? = nil
    
    func kk_modelKey(from property: Property) -> ConvertibleKey {
        return property.name.kk.underlineCased()
    }
}
