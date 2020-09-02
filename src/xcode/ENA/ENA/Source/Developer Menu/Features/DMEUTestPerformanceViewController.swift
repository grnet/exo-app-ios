//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit
import ExposureNotification
#if !RELEASE
class DMEUTestPerformanceViewController: UIViewController {

	private let availableCountries = [
		"DE", "UK", "FR", "IT", "SP", "PL",
		"RO", "NL", "BE", "CZ", "EL", "SE",
		"PT", "HU", "AT", "CH", "BG", "DK",
		"FI", "SK", "NO", "IE", "HR", "SI",
		"LT", "LV", "EE", "CY", "LU", "MT", "IS"
	]
//	private let availableCountries = [
//		"DE"
//	]

	let textView = UITextView()
	let benchmark = Benchmark()
	let client: Client
	let exposureDetector: ExposureDetector
	let downloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "EU_Test")

	init(
			client: Client,
			exposureDetector: ExposureDetector
	) {
		self.client = client
		self.exposureDetector = exposureDetector
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		createViews()
		// Do any additional setup after loading the view.
	}
}

// MARK: Buttons Logic
extension DMEUTestPerformanceViewController {

	@objc
	private func resetDidTap(_ sender: UIButton) {

		let okAction = UIAlertAction(title: "YES", style: .destructive) { _ in
			self.downloadedPackagesStore.reset()
		}

		let cancelAction = UIAlertAction(title: "NO", style: .cancel, handler: nil)
		let alertView = UIAlertController(title: "OK", message: "Clear Cache?", preferredStyle: .alert)
		alertView.addAction(okAction)
		alertView.addAction(cancelAction)
		self.present(alertView, animated: true, completion: nil)
	}


	@objc
	private func downloadBtnDidTap(_ sender: UIButton) {
		logMessage("Start to download the days.")
		benchmark.start()
		availableCountries.forEach(downloadKeysForCountry)
	}


	@objc
	private func calcRiskBtnDidTap(_ sender: UIButton) {

		let bm = Benchmark()
		bm.start()
		logMessage("Start to download Configuration.")
		client.exposureConfiguration { config in
			guard let exposureConfig = config else {
				self.logMessage("Fail to download the ExposureConfig file.", isError: true)
				return
			}
			self.logMessage("Finish downloading Configuration.")
			self.logMessage("Start to calculate risk level.")
			guard let urls = self.writtenPackages()?.urls else {
				self.logMessage("Fail to get the urls")
				return
			}


			_ = self.exposureDetector.detectExposures(
					configuration: exposureConfig,
					diagnosisKeyURLs: urls
			) { _, error in
				if let error = error as? ENError {
					self.logMessage("Error occurs while calculating risk level. The error code is \(error.errorCode)", isError: true)
					return
				}
				self.logMessage("✅ Finish calculating risk level. It takes \(bm.end()) seconds")
			}
		}
	}


	private func downloadKeysForCountry(_ country: String) {
		logMessage("Downloading keys for country code: \(country)")
		client.availableDays(forCountry: country) {[weak self] result in
			switch result {
			case let .success(days):
				self?.logMessage("There are \(days.count) Keys. Days to download: \(days.joined(separator: "\n"))")
				self?.downloadKeysForDays(days)
			case .failure:
				self?.logMessage("Fail to download the text.")
			}
		}
	}

	private func downloadKeysForDays(_ days: [String]) {
		logMessage("Start to download key packages... ")
		client.fetchDays(days) { daysResult in
			self.logMessage("✅ Finish download the result. It takes \(self.benchmark.end()) seconds")
			let hoursResult = HoursResult(errors: [], bucketsByHour: [:], day: "")
			let daysAndHours = FetchedDaysAndHours(hours: hoursResult, days: daysResult)
			self.logMessage("Persisting the packages")
			self.downloadedPackagesStore.addFetchedDaysAndHours(daysAndHours)
			self.logMessage("✅ Persisting is done!")
		}
	}
}

// MARK: Helper methods
extension DMEUTestPerformanceViewController {
	private func logMessage(_ message: String, isError: Bool = false) {
		DispatchQueue.main.async {
			if isError {
				self.textView.text.append("❌")
			}
			self.textView.text.append(message)
			self.textView.text.append("\n")
		}
	}


	private func writtenPackages() -> WrittenPackages? {
		let fileManager = FileManager()
		let rootDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		do {
			try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)
			
//			let packages = downloadedPackagesStore.allPackages(onlyHours: false)
//			let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: packages)
//			return writer.writeAllPackages()

			var writtenPackageURLs = [URL]()
			for day in downloadedPackagesStore.allDays() {
				autoreleasepool {
				let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: [])
				var keyPackage = downloadedPackagesStore.package(for: day)
				writtenPackageURLs.append(contentsOf: writer.writePackage(keyPackage!)!)
				keyPackage = nil
				}
			}
			return WrittenPackages(urls: writtenPackageURLs)
		} catch {
			logMessage("Fail to create WrittenPackages", isError: true)
			return nil
		}
	}
}


// MARK: Create the Views
extension DMEUTestPerformanceViewController {

	private func createViews() {
		//Download Button
		let downloadBtn = UIButton(type: .roundedRect)
		downloadBtn.translatesAutoresizingMaskIntoConstraints = false
		downloadBtn.setTitle("Download", for: .normal)
		downloadBtn.addTarget(self, action: #selector(downloadBtnDidTap(_:)), for: .touchUpInside)
		view.addSubview(downloadBtn)
		downloadBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		downloadBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true


		//Risk calculation button
		let checkBtn = UIButton(type: .roundedRect)
		checkBtn.translatesAutoresizingMaskIntoConstraints = false
		checkBtn.setTitle("Check Risk", for: .normal)
		checkBtn.addTarget(self, action: #selector(calcRiskBtnDidTap(_:)), for: .touchUpInside)
		view.addSubview(checkBtn)
		checkBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		checkBtn.leadingAnchor.constraint(equalTo: downloadBtn.trailingAnchor, constant: 40).isActive = true

		//Reset button
		let resetBtn = UIButton(type: .roundedRect)
		resetBtn.translatesAutoresizingMaskIntoConstraints = false
		resetBtn.setTitle("Reset", for: .normal)
		resetBtn.addTarget(self, action: #selector(resetDidTap(_:)), for: .touchUpInside)
		view.addSubview(resetBtn)
		resetBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		resetBtn.leadingAnchor.constraint(equalTo: checkBtn.trailingAnchor, constant: 40).isActive = true


		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isEditable = false
		view.addSubview(textView)
		textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
		textView.topAnchor.constraint(equalTo: checkBtn.bottomAnchor, constant: 10).isActive = true
	}
}


class Benchmark {
	private var startTime: TimeInterval = 0
	func start() {
		startTime = Date().timeIntervalSince1970
	}
	func end() -> TimeInterval {
		Date().timeIntervalSince1970 - startTime
	}
}
#endif
