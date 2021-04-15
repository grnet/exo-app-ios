//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_06_DeltaOnboarding: XCTestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
	}

    func testDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}

		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
				
		// Close (X) Button
		XCTAssertTrue(XCUIApplication().navigationBars["ENA.DeltaOnboardingV15View"].buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5))
		
	}
	
	func test_screenshotDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_V15"
		
		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
	}
	
	func test_DeltaOnboardingScreenCloseButton() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.3"])
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		
		XCTAssert(app.staticTexts["AppStrings.DeltaOnboarding.title"].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons["AppStrings.AccessibilityLabel.close"].exists)
		
		// close delta onboarding
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
		
		XCTAssertFalse(app.staticTexts["AppStrings.DeltaOnboarding.title"].exists)
		XCTAssertFalse(app.staticTexts["AppStrings.AccessibilityLabel.close"].exists)
			
	}

}
