//
//  ListSectionHeaderView.swift
//  ShopiList
//
//  Created by John Peng on 2018-09-12.
//  Copyright © 2018 Junhao Peng. All rights reserved.
//

import UIKit

protocol SectionHeaderViewDelegate {
    func sectionHeaderView(sectionHeaderView: ListSectionHeaderView, section: Int)
}

class ListSectionHeaderView: UITableViewHeaderFooterView {

    var section: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    @IBAction func toggleOpen() {
        self.disclosureButton.isSelected = !self.disclosureButton.isSelected
        self.delegate?.sectionHeaderView(sectionHeaderView: self, section: self.section!)
    }
    var delegate: SectionHeaderViewDelegate?
    
    override func awakeFromNib() {
        self.disclosureButton.setImage(UIImage(named: "arrow_up"), for: UIControlState.selected)
        self.disclosureButton.setImage(UIImage(named: "arrow_down"), for: UIControlState.normal)
    }

}
