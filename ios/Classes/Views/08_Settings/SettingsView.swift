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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class SettingsView: UIViewController {

	@IBOutlet private var cellColumns: UITableViewCell!
	@IBOutlet private var cellGridMargin: UITableViewCell!
	@IBOutlet private var cellPageMargin: UITableViewCell!
	@IBOutlet private var cellGridCorner: UITableViewCell!
	@IBOutlet private var cellPageCorner: UITableViewCell!

	@IBOutlet private var segmentedColumns: UISegmentedControl!
	@IBOutlet private var segmentedGridMargin: UISegmentedControl!
	@IBOutlet private var segmentedPageMargin: UISegmentedControl!
	@IBOutlet private var segmentedGridCorner: UISegmentedControl!

	private let arrayColumns: [Int] = [2, 3, 4, 5]
	private let arrayGridMargin: [CGFloat] = [0.0, 2.5, 5.0, 10.0]
	private let arrayPageMargin: [CGFloat] = [0.0, 5.0, 10.0, 20.0]
	private let arrayGridCorner: [CGFloat] = [0.0, 2.5, 5.0, 10.0]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Settings"

		setupSegmented(segmentedColumns, arrayColumns)
		setupSegmented(segmentedGridMargin, arrayGridMargin)
		setupSegmented(segmentedPageMargin, arrayPageMargin)
		setupSegmented(segmentedGridCorner, arrayGridCorner)

		loadValues()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		saveValues()
	}
}

// MARK: - Setup methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setupSegmented<T: CustomStringConvertible>(_ segmented: UISegmentedControl, _ array: [T]) {

		while (segmented.numberOfSegments > 0) {
			segmented.removeSegment(at: 0, animated: false)
		}

		for (index, value) in array.enumerated() {
			segmented.insertSegment(withTitle: String(describing: value), at: index, animated: false)
		}
	}
}

// MARK: - Load, Save methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadValues() {

		if let index = arrayColumns.firstIndex(of: Grid.gridColumns)	{ segmentedColumns.selectedSegmentIndex = index		}
		if let index = arrayGridMargin.firstIndex(of: Grid.gridMargin)	{ segmentedGridMargin.selectedSegmentIndex = index	}
		if let index = arrayPageMargin.firstIndex(of: Grid.pageMargin)	{ segmentedPageMargin.selectedSegmentIndex = index	}
		if let index = arrayGridCorner.firstIndex(of: Grid.gridCorner)	{ segmentedGridCorner.selectedSegmentIndex = index	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func saveValues() {

		Grid.gridColumns = arrayColumns[segmentedColumns.selectedSegmentIndex]
		Grid.gridMargin = arrayGridMargin[segmentedGridMargin.selectedSegmentIndex]
		Grid.pageMargin = arrayPageMargin[segmentedPageMargin.selectedSegmentIndex]
		Grid.gridCorner = arrayGridCorner[segmentedGridCorner.selectedSegmentIndex]
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 }
		if (section == 1) { return 2 }
		if (section == 2) { return 2 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 0) { return "Number of columns"	}
		if (section == 1) { return "Margin value"		}
		if (section == 2) { return "Corner radius"		}

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellColumns	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellGridMargin	}
		if (indexPath.section == 1) && (indexPath.row == 1) { return cellPageMargin	}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellGridCorner	}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellPageCorner	}

		return UITableViewCell()
	}
}
