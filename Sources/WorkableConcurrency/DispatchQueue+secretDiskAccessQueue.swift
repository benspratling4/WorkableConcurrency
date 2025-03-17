//
//  SingleDiskQueue.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch




extension DispatchQueue {
	/**
	 Apple has secert threads on which they perform disk access, that otherwise appears synchronous and concurrent.
	 But async / await has a limit number of threads which will deadlock
	 So this is one serial queue on which the other methods may synchronize their work to prevent thread pool exhaustion.
	 
	 */
	public static let secretDiskAccessQueue:DispatchQueue = DispatchQueue(label: "com.benspratling.workableconcurrency.secretDiskAccessQueue")
	
}

