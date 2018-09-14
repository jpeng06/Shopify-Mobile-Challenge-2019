//
//  ProductInfo.swift
//  ShopiList
//
//  Created by John Peng on 2018-09-13.
//  Copyright © 2018 Junhao Peng. All rights reserved.
//

import UIKit

class ProductInfo: NSObject {
    
    var title: String
    
    var tags: [String]
    
    var image: String
    
    var variants: [[String: Any]]
    
    init(productTile: String, productTags: [String], productImg: String, productVariants: [[String: Any]] ) {
        
        self.title = productTile
        self.image = productImg
        self.tags = productTags
        self.variants = productVariants

    }
    
}

