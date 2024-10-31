//
// Copyright (c) 2024 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class MainView: UIViewController {

	@IBOutlet private var tableView: UITableView!

	private var items = ["Waterfall", "Squared", "Search", "Settings"]

	private var random: String = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Midjourney"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		fetchRandom()
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MainView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchRandom() {

		Backend.random { [weak self] word, error in
			guard let self = self else { return }
			if let error = error {
				ProgressHUD.failed(error)
			} else if let word = word {
				random = word
			}
		}
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MainView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionWaterfall() {

		if (random.notEmpty) {
			let gridView = GridView(random)
			navigationController?.pushViewController(gridView, animated: true)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSquared() {

		if (random.notEmpty) {
			let squaredView = SquaredView(random)
			navigationController?.pushViewController(squaredView, animated: true)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSearch() {

		let searchView = SearchView()
		navigationController?.pushViewController(searchView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSettings() {

		navigationController?.pushViewController(SettingsView(), animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MainView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return items.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

		let item = items[indexPath.section]
		cell.textLabel?.text = item

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MainView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let item = items[indexPath.section]

		if (item == "Waterfall")	{ actionWaterfall()	}
		if (item == "Squared")		{ actionSquared()	}
		if (item == "Search")		{ actionSearch()	}
		if (item == "Settings")		{ actionSettings()	}
	}
}
