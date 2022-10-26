//
//  File.swift
//  
//
//  Created by Ben Spratling on 10/25/22.
//

import Foundation
import Combine

//not tested
public extension Publisher {
	
	///If your publisher sends multiple values (or none) and can throw an error use this to output a stream of values
	func asyncThrowingStream()->AsyncThrowingStream<Output, some Error> {
		AsyncThrowingStream { continuation in
			Task {
				let cycle = RetainCycleCancellable()
				return try await withTaskCancellationHandler {
					try Task.checkCancellation()
					cycle.cancellable = sink(receiveCompletion: { result in
						guard cycle.cancellable != nil else { return }
						switch result {
						case .finished:
							continuation.finish()
						case .failure(let error):
							continuation.finish(throwing:error)
						}
						cycle.cancellable = nil
					}, receiveValue: { value in
						continuation.yield(value)
					})
				} onCancel: {
					cycle.cancellable?.cancel()
				}
			}
		}
	}
	
}

//not tested
public extension Publisher where Failure == Never {
	
	///If your publisher sends multiple values (or none) use this to output a stream of values
	func asyncStream()->AsyncStream<Output> {
		AsyncStream { continuation in
			Task {
				let cycle = RetainCycleCancellable()
				return await withTaskCancellationHandler {
					do {
						try Task.checkCancellation()
					} catch {
						continuation.finish()	//TODO: should I do this?
						return
					}
					cycle.cancellable = sink(receiveCompletion: { result in
						guard cycle.cancellable != nil else { return }
						continuation.finish()
						cycle.cancellable = nil
					}, receiveValue: { value in
						guard cycle.cancellable != nil else { return }
						continuation.yield(value)
					})
				} onCancel: {
					cycle.cancellable?.cancel()
				}
			}
		}
	}
	
}
