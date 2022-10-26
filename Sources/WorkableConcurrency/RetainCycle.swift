//
//  File.swift
//  
//
//  Created by Ben Spratling on 10/25/22.
//

import Foundation
import Combine

/**
 Maintain a reference to a publisher / subscriber chain until a .sink completes
 
	let cycle = RetainCycleCancellable()
	cycle.cancellable = publisher
		.sink(receiveCompletion: { result in
			defer {
				cycle.cancellable = nil
			}
			//code dealing with result here
		}, receiveValue: { value in
			//code dealing with value here
		})
 
 There is no need to create instance variables to keep the publisher chain live in memory for one-off publishers, use this instead
 */
public class RetainCycleCancellable {
	public init() {}
	public var cancellable:AnyCancellable?
	public var valueProvided:Bool = false
}
