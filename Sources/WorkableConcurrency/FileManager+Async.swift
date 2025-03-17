//
//  FileManager+Async.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch




extension FileManager {
	
	public func asyncFileExists(atPath path: String)async->(exists:Bool, isDirectory:Bool) {
		await withCheckedContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async(qos:Task.currentPriority.dispatchQoS) {
				var isDirectory: ObjCBool = false
				let result = self.fileExists(atPath: path, isDirectory: &isDirectory)
				continuation.resume(returning: (result, isDirectory.boolValue))
			}
		}
	}
	
	public func asyncContentsOfDirectory(at url:URL)async throws -> [URL] {
		return try await withCheckedThrowingContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async(qos:Task.currentPriority.dispatchQoS) {
				do {
					let result = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
					continuation.resume(returning: result)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	public func asyncCreateDirectory(at url:URL, withIntermediateDirectories:Bool)async throws {
		try await withCheckedThrowingContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async(qos:Task.currentPriority.dispatchQoS) {
				do {
					try self.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories)
					continuation.resume()
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	
}
