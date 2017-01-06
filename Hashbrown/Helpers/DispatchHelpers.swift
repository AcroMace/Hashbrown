//
//  DispatchHelpers.swift
//  Hashbrown
//
//  Created by Andy Cho on 2016-09-02.
//  Copyright © 2016 Andy Cho. All rights reserved.
//

import UIKit

/**
 Run the block asynchronously in the background queue

 - parameter block: Block to run asynchronously
 */
func dispatch_background(_ block: @escaping ()->()) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

/**
 Run the block asynchronously in the main queue

 - parameter block: Block to run asynchronously
 */
func dispatch_main_async(_ block: @escaping ()->()) {
    DispatchQueue.main.async(execute: block)
}
