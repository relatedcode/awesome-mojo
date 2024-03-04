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
protocol SearchDelegate: AnyObject {

	func didSearchItem(_ search: String)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class SearchView: UIViewController {

	weak var delegate: SearchDelegate?

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var suggestions: [String] = []

	private var isLoading = false
	private var isWaiting = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Search"

		let image = UIImage(systemName: "xmark")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionDismiss))

		createObservers()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		searchBar.becomeFirstResponder()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

	   super.viewWillDisappear(animated)

	   dismissKeyboard()
	   removeObservers()
   }
}

// MARK: - Keyboard methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func dismissKeyboard() {

		view.endEditing(true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		let keyboardWillShow = UIResponder.keyboardWillShowNotification
		let keyboardWillHide = UIResponder.keyboardWillHideNotification

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: keyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: keyboardWillHide, object: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeObservers() {

		NotificationCenter.default.removeObserver(self)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillShow(_ notification: NSNotification) {

		if let userInfo = notification.userInfo {
			if let frameKeyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
				let insets = UIEdgeInsets(top: 0, left: 0, bottom: frameKeyboard.height, right: 0)
				tableView.contentInset = insets
				tableView.scrollIndicatorInsets = insets
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillHide(_ notification: NSNotification) {

		let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		tableView.contentInset = insets
		tableView.scrollIndicatorInsets = insets
	}
}

// MARK: - Backend methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchItems() {

		let text = searchBar.text ?? ""

		if (isLoading) {
			isWaiting = true
		} else {
			if (text.isEmpty) {
				suggestions.removeAll()
				tableView.reloadData()
			} else {
				searchItems(text)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchItems(_ text: String) {

		isLoading = true
		Backend.search(text) { [weak self] array, error in
			guard let self = self else { return }
			isLoading = false
			if let error = error {
				ProgressHUD.failed(error)
			} else if let array = array {
				suggestions = array
				tableView.reloadData()
			}
			checkWaiting()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func checkWaiting() {

		if (isWaiting) {
			isWaiting = false
			searchItems()
		}
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSearch() {

		let text = searchBar.text ?? ""

		if !text.isEmpty {
			actionSearch(text)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSearch(_ text: String) {

		delegate?.didSearchItem(text)

		dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return suggestions.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		if (indexPath.section < suggestions.count) {
			let suggestion = suggestions[indexPath.section]

			cell.textLabel?.text = suggestion
			cell.detailTextLabel?.text = suggestion
			cell.detailTextLabel?.textColor = .gray
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let suggestion = suggestions[indexPath.section]

		actionSearch(suggestion)
	}
}
// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SearchView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		searchItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()

		searchItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()

		actionSearch()
	}
}
