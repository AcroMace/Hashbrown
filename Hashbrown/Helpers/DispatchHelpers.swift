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
func dispatch_background(block: dispatch_block_t) {
    // This becomes `DispatchQueue.global(attributes: [.qosDefault]).async` in Swift 3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
}

/**
 Run the block asynchronously in the main queue

 - parameter block: Block to run asynchronously
 */
func dispatch_main_async(block: dispatch_block_t) {
    // This becomes `DispatchQueue.main.async` in Swift 3
    dispatch_async(dispatch_get_main_queue(), block)
}
