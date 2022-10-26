//
//  XCTestCase+awaitExpectation.swift
//  
//
//  Created by Ben Spratling on 10/25/22.
//

import Foundation
import XCTest


public extension XCTestCase {
	//not tested
	func expectationAwait<T>(timeout:TimeInterval = 10.0, function:String = #function,  _ work:@escaping ((T)->(Void))->(Void))throws -> T {
		let expectation = self.expectation(description: function + " expectationAwait " + String(describing: work))
		var value:T?
		work() {
			value = $0
			expectation.fulfill()
		}
		wait(for: [expectation], timeout: timeout)
		guard let value else {
			throw AsyncError.expectationNotFulfilled
		}
		return value
	}
	
	
}


public enum AsyncError :Error {
	case expectationNotFulfilled
}




