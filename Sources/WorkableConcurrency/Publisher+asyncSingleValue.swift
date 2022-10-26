//
//  File.swift
//  
//
//  Created by Ben Spratling on 10/25/22.
//

import Foundation
import Combine



public extension Publisher {
	
	/**
	 Use this to adapt a Publisher which sends only a single value and/or fails.
	 and use it as a
	 */
	func asyncThrowingSingleValue() async throws ->Output {
		let cycle = RetainCycleCancellable()
		let continuationWrapper = Wrapper<CheckedContinuation<Output, Error>>()
		return try await withTaskCancellationHandler(operation: {
			try await withCheckedThrowingContinuation { continuation in
				//Check for a pre-existing cancellation, which almost never happens
				do {
					try Task.checkCancellation()
				} catch {
					//the cancellation handler will not have thrown the cancellation error yet because it did not have the continuation yet
					continuation.resume(throwing: CancellationError())
					return
				}
				//proceed with the continuation
				continuationWrapper.value = continuation
				cycle.cancellable = sink(receiveCompletion: { result in
					guard cycle.cancellable != nil else { return }
					defer {
						cycle.cancellable = nil
					}
					guard case .failure(let error) = result else { return }
					continuation.resume(throwing: error)
					
				}, receiveValue: { value in
					guard cycle.cancellable != nil else { return }
					cycle.valueProvided = true
					continuation.resume(returning: value)
					cycle.cancellable = nil
				})
			}
		}, onCancel: {
			cycle.cancellable?.cancel()
			cycle.cancellable = nil
			continuationWrapper.value?.resume(throwing: CancellationError())
			continuationWrapper.value = nil
		})
	}
	
}


/*
 //still trying to figure this one out.
public extension Publisher where Failure == Never {
	
	///if your publisher should send one value once, and then complete and also never fail, use this to convert it into a safe call to an async throwing function
	func asyncSingleValue() async ->Output {
		let cycle = RetainCycleCancellable()
		let continuationWrapper = Wrapper<CheckedContinuation<Output, Never>>()
		return await withTaskCancellationHandler(operation: {
			await withCheckedContinuation { continuation in
				continuationWrapper.value = continuation
				do {
					try Task.checkCancellation()
				} catch {
					//TODO:  um... how do you cancel a continuation which can't fail?.....
					return
				}
				cycle.cancellable = sink(receiveValue: { value in
					guard cycle.cancellable != nil else { return }
					cycle.valueProvided = true
					continuation.resume(returning: value)
					cycle.cancellable = nil
				})
			}
		}, onCancel: {
			cycle.cancellable?.cancel()
			cycle.cancellable = nil
//			continuationWrapper.value?.resume(throwing: CancellationError())
		})
	}
	
}
*/


public enum AsyncCombineError : Error {
	case singleValuePublisherFailedToProvideValue
}



class Wrapper<T> {
	var value:T?
	init(value:T? = nil) {
		self.value = value
	}
}
