# WorkableConcurrency
 You like Swift concurrency but need some stuff to make it actually usable.
 
 This package contains two dynamic Swift libraries, one intended for your apps, (WorkableConcurrency) and one intended for your unit test suites (WorkableXCTestConcurrency).
 
 
## awaiting Combine
 
 Do you have older code in Combine and want to add adapters so you can start `await` it today? 
 
### Single-value Publishers
 
 If your `Publisher` publishes a single value and then completes, such as a network call, and you'd like it adapted to use `async`, tack on 
 `asyncThrowingSingleValue()` to the end of your publisher chain, and `try await` it like a normal `async` method.
 
 
 Where you had:
 ```swift
var value:Value
let publisher:Publisher<Value, Error> = ...
func kickOffFetch() {
	let cancellar = RetainCycleCancellable()
	cancellar.cancellable = publisher.receive(on:DispatchQueue.main)
		.sink(receiveCompletion: { result in
			if case .failure(let error): {
				//TODO: show error message
			}
			cancellar.cancellable = nil
		}, receiveValue: { [weak self] value in
			self?.value = value
		}
	}
}
``` 
 
Now write:
```swift
@Published var value:Value
let publisher:Publisher<Value, Error> = ...
func kickOffFetch() {
	Task {  [weak self, publisher] in
		let fetcher = Task.detached {
			try await publisher.asyncThrowingSingleValue()
		}
		self?.value = try await fetcher.value
	}
}
``` 
Doing the `detached` `Task` inside the regular `Task` keeps you on the right `actor` for setting `value`.

 
 ### Multiple values Publishers
 
 
 //TODO: write me
 
 
 
 ## URLSession in ealier OS versions
 
 In iOS 15, URLSession added a fantastic async method for data.
 
 ```swift
 	func data(for request: URLRequest) async throws -> (Data, URLResponse)
```

but it didn't back-deploy to older OS's.

This package adds this method as far back as iOS 13, but is safe to import in later os versions where the OS declares it

```swift
@available(macOS, introduced: 10.15, obsoleted:12.0)
@available(tvOS, introduced: 13.0, obsoleted:15.0)
@available(iOS, introduced: 13.0, obsoleted:15.0)
extension URLSession {
	public func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
```
 
 
 
 ## await and XCTestCase
 
 //TODO: write me
  
