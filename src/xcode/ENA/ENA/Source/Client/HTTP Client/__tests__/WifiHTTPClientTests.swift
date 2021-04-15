//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class WifiHTTPClientTest: XCTestCase {

	func testWHEN_WifiClient_THEN_wifiOnlyIsActive() {
		// WHEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, true)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiFalse_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// WHEN
		wifiClient.updateSession(wifiOnly: false)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, false)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiTrue_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// WHEN
		wifiClient.updateSession(wifiOnly: true)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, true)
	}

	func testWHEN_WifiOnlyClient_THEN_disableHourlyDownloadIsFalse() {
		// WHEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// THEN
		XCTAssertEqual(wifiClient.disableHourlyDownload, false)
	}

	func testGIVEN_WifiOnlyClient_WHEN_DisableHourlyDownloadIsTrue_THEN_NoRequestIsSent() throws {
		let stack = MockNetworkStack( httpStatus: 200, responseData: nil)
		let wifiOnlyHTTPClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		let successExpectation = expectation(description: "ignore request")

		// WHEN
		wifiOnlyHTTPClient.disableHourlyDownload = true

		// THEN
		wifiOnlyHTTPClient.fetchHour(12, day: .formattedToday(), country: "GR") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("request wasn't ignored but this was expected")
			case .failure:
				break
			}
		}
		waitForExpectations(timeout: .medium)
	}

}
