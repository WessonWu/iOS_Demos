//
//  WeakReference.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/13.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

public final class WeakReference<Element: AnyObject> {
    public weak var value: Element?
    public init?(_ value: Element?) {
        if value == nil {
            return nil
        }
        self.value = value
    }
}

typealias ViewControllerRef = WeakReference<UIViewController>
