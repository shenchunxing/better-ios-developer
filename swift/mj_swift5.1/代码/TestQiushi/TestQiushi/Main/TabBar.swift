//
//  TabBar.swift
//  TestQiushi
//
//  Created by MJ Lee on 2019/8/13.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

import UIKit

class TabBar: UITabBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for button in subviews where button is UIControl  {
            var frame = button.frame
            frame.origin.y = -2
            button.frame = frame
        }
    }
}
