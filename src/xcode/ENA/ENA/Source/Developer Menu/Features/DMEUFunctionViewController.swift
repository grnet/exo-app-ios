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

#if !RELEASE

import UIKit

final class DMEUFunctionViewController: UITableViewController {


	// MARK: Creating a Configuration View Controller

	init(
			client: Client,
			exposureManager: ExposureManager
	) {
		self.client = client
		self.exposureManager = exposureManager
		super.init(style: .plain)
		title = "⚙️ Interop Functions Test"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties

	private let client: Client
	private let exposureManager: ExposureManager

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(
				DMConfigurationCell.self,
				forCellReuseIdentifier: DMConfigurationCell.reuseIdentifier
		)
	}

	// MARK: UITableViewController

	override func tableView(
			_ tableView: UITableView,
			cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DMConfigurationCell.reuseIdentifier, for: indexPath)
		let title: String?
		let subtitle: String?
		switch indexPath.row {
		case 0:
			title = "Performance Test (Foreground)"
			subtitle = "Some performance test on foreground"
		case 1:
			title = "Performance Test (Background)"
			subtitle = "Test the performance in the background mode."
		default:
			title = nil
			subtitle = nil
		}
		cell.textLabel?.text = title
		cell.detailTextLabel?.text = subtitle
		cell.detailTextLabel?.numberOfLines = 0
		return cell
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		2
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var vc: UIViewController?
		switch indexPath.row {
		case 0:
			vc = DMEUTestPerformanceViewController(client: client, exposureDetector: exposureManager)
		default:
			return
		}
		guard let viewController = vc else {
			return
		}
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}


#endif
