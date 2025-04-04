//
//  Data+Async.swift
//  WorkableConcurrency
//
//  Created by Ben Spratling on 3/17/25.
//

import Foundation
import Dispatch
import System



@available(macOS 11.0, iOS 14.0, watchOS 7.0, *)
extension Data {
	
	public func asyncWrite(to url:URL)async throws {
		guard url.scheme == "file" else {
			throw CocoaError(.fileWriteUnsupportedScheme)
		}
		guard let filePath = FilePath(url) else {
			throw CocoaError(.fileWriteInvalidFileName)
		}
		let queue = DispatchQueue.global(qos:Task.currentPriority.dispatchQoSClass)
		let fileDescriptor = try FileDescriptor.open(filePath, .writeOnly)
		defer {
			do {
				try fileDescriptor.close()
			} catch {
				//errors can't be thrown from a defer
			}
		}
		//avoid copying bytes if posisble
		let data:DispatchData = withContiguousStorageIfAvailable { buffer in
			DispatchData(bytesNoCopy:UnsafeRawBufferPointer(buffer), deallocator: .custom(nil, {
				//ignore, self owns the bytes
			}))
		}
		?? self.withUnsafeBytes { buffer in
			DispatchData(bytes: buffer)
		}
		try await withCheckedThrowingContinuation { continuation in
			DispatchIO.write(
				toFileDescriptor: fileDescriptor.rawValue
				,data: data
				,runningHandlerOn: queue) { data, error in
					if error == 0 {
						continuation.resume()
					}
					else {
						continuation.resume(
							throwing:
								CocoaError(
									errno:error
									,operation: .write
									,userInfo: [NSURLErrorKey:url]
								)
						)
					}
				}
		}
	}
	
	
	public init(asyncContentsOf url:URL)async throws {
		guard url.scheme == "file" else {
			throw CocoaError(.fileReadUnsupportedScheme)
		}
		guard let filePath = FilePath(url) else {
			throw CocoaError(.fileReadInvalidFileName)
		}
		let queue = DispatchQueue.global(qos:Task.currentPriority.dispatchQoSClass)
		let fileDescriptor = try FileDescriptor.open(filePath, .readOnly)
		defer {
			do {
				try fileDescriptor.close()
			} catch {
				//errors can't be thrown from a defer
			}
		}
		self = try await withCheckedThrowingContinuation({ continuation in
			DispatchIO.read(
				fromFileDescriptor: fileDescriptor.rawValue
				,maxLength: Int(SIZE_MAX)//means read to end of file
				,runningHandlerOn: queue) { data, error in
					guard error == 0 else {
						continuation.resume(
							throwing:
								CocoaError(
									errno:error
									,operation: .read
									,userInfo: [NSURLErrorKey:url]
								)
							)
						return
					}
					var subData = Data()
					data.enumerateBytes { buffer, byteIndex, stop in
						//TODO: should I throw when this fails?
						guard let baseAddress = buffer.baseAddress else { return }
						subData.append(baseAddress, count: buffer.count)
					}
					continuation.resume(returning: subData)
				}
		})
	}
	
}
