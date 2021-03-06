//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

final class URLSessionConvenienceTests: XCTestCase {
	func testExecuteRequest_Success() {
		let url = URL(staticString: "https://localhost:8080")
		let dateFormatter = ENAFormatter.httpDateHeaderFormatter
		let dateString = "Wed, 07 Oct 2020 12:17:01 GMT"

		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: ["Date": dateString]
			),
			error: nil
		)

		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Success")
		session.response(for: request) { result in
			switch result {
			case let .success(response):
				XCTAssertNotNil(response.body)
				XCTAssertEqual(response.statusCode, 200)
				XCTAssertEqual(response.body, data)
				XCTAssertNotNil(response.httpResponse.dateHeader)
				XCTAssertEqual(response.httpResponse.dateHeader, dateFormatter.date(from: dateString))
				expectation.fulfill()
			case let .failure(error):
				XCTFail("should not fail but did with: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func testExecuteRequest_SuccessAcceptsNotFound() {
		let url = URL(staticString: "https://localhost:8080")

		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 404,
				httpVersion: nil,
				headerFields: nil
			),
			error: nil
		)
		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Success")
		session.response(for: request) { result in
			switch result {
			case let .success(response):
				XCTAssertEqual(response.statusCode, 404)
				XCTAssertEqual(response.body, data)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("should not fail but did with: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func testExecuteRequest_FailureWithError() {
		let url = URL(staticString: "https://localhost:8080")
		let dateFormatter = ENAFormatter.httpDateHeaderFormatter
		let dateString = "Wed, 07 Oct 2020 12:17:01 GMT"

		let notConnectedError = NSError(
			domain: NSURLErrorDomain,
			code: NSURLErrorNotConnectedToInternet,
			userInfo: nil
		)
		let data = Data("hello".utf8)
		let session = MockUrlSession(
			data: data,
			nextResponse: HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: ["Date": dateString]
			),
			error: notConnectedError
		)
		let request = URLRequest(url: url)

		let expectation = self.expectation(description: "Fails")
		session.response(for: request) { result in
			switch result {
			case .success:
				XCTFail("should succeed")
			case let .failure(error):
				if case let .httpError(_, httpResponse) = error {
					XCTAssertNotNil(httpResponse.dateHeader)
					XCTAssertEqual(httpResponse.dateHeader, dateFormatter.date(from: dateString))
				} else {
					XCTFail("Expected an httpError with httpResponse.")
				}
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}
}
