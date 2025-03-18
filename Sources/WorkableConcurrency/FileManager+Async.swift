//
//  FileManager+Async.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch



/**
 See docs for DispatchQueue.secretDiskAccessQueue as to why these methods exist.
 */
extension FileManager {
	
	public func asyncFileExists(atPath path: String)async->(exists:Bool, isDirectory:Bool) {
		await performingAsync {
			var isDirectory: ObjCBool = false
			let result = self.fileExists(atPath: path, isDirectory: &isDirectory)
			return (result, isDirectory.boolValue)
		}
	}
	
	public func asyncContentsOfDirectory(at url:URL)async throws -> [URL] {
		try await performingAsyncThrowing {
			try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
		}
	}
	
	public func asyncCreateDirectory(at url:URL, withIntermediateDirectories:Bool)async throws {
		try await performingAsyncThrowing {
			try self.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories)
		}
	}
	
	public func asyncMoveItem(at origin:URL, to destination:URL)async throws {
		try await performingAsyncThrowing {
			try self.moveItem(at: origin, to: destination)
		}
	}
	
	public func asyncRemoveItem(at url:URL)async throws {
		try await performingAsyncThrowing {
			try self.removeItem(at: url)
		}
	}
	
	public func asyncCopyItem(at origin:URL, to destination:URL)async throws {
		try await performingAsyncThrowing {
			try self.copyItem(at: origin, to: destination)
		}
	}
	
	func performingAsyncThrowing<T>(_ work:@escaping()throws->T)async throws->T {
		try await withCheckedThrowingContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async(qos:Task.currentPriority.dispatchQoS) {
				do {
					let result = try work()
					continuation.resume(returning: result)
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
	
	func performingAsync<T>(_ work:@escaping()->T)async->T {
		await withCheckedContinuation { continuation in
			DispatchQueue.secretDiskAccessQueue.async(qos:Task.currentPriority.dispatchQoS) {
				let result = work()
				continuation.resume(returning: result)
			}
		}
	}
	
}
