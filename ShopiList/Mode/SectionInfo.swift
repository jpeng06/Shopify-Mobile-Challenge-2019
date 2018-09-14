//
//  SectionInfo.swift
//  ShopiList
//
//  Created by John Peng on 2018-09-12.
//  Copyright © 2018 Junhao Peng. All rights reserved.
//

import UIKit

class SectionInfo: NSObject {
    var open: Bool = true
    var itemsInSection: NSMutableArray = []
    var sectionTitle: String?
    
    init(itemsInSection: NSMutableArray, sectionTitle: String) {
        self.itemsInSection = itemsInSection
        self.sectionTitle = sectionTitle
    }
}
