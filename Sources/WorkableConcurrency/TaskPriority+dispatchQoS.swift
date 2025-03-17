//
//  TaskPriority+dispatchQoS.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch



extension TaskPriority {
	
	public var dispatchQoSClass: DispatchQoS.QoSClass {
		switch self {
		case .high:
			return .userInteractive
			
		case .medium:
			return .userInitiated
			
		case .low, .utility:
			return .utility
			
		case .background:
			return .background
			
		default:
			return .default
		}
	}
	
	
	public var dispatchQoS:DispatchQoS {
		DispatchQoS(qosClass: self.dispatchQoSClass, relativePriority: 0)
	}
}
