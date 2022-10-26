//
//  URLSession+asyncData.swift
//  
//
//  Created by Ben Spratling on 10/25/22.
//

import Foundation


@available(macOS, introduced: 10.15, obsoleted:12.0)
@available(tvOS, introduced: 13.0, obsoleted:15.0)
@available(iOS, introduced: 13.0, obsoleted:15.0)
extension URLSession {
	
	///You thought this was only in iOS 15 and later, well, this adds it before that.
	///Also, the delegate doesn't actually work... yet
	public func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
		return try await dataTaskPublisher(for: request)
			.asyncThrowingSingleValue()
	}
 }

