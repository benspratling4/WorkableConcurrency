//
//  URL+async resourceValues.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch





extension URL {
	
	public func asyncResourceValues(includingKeys keys: Set<URLResourceKey>) async throws -> URLResourceValues {
		try await withCheckedThrowingContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async {
				do {
					let values = try self.resourceValues(forKeys: keys)
					continuation.resume(returning: values)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
		
}





