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
class SquaredView: UIViewController {

	@IBOutlet private var viewTitle: UIView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var labelSubtitle: UILabel!

	@IBOutlet private var collectionView: UICollectionView!

	private var page: Int = 0
	private var total: Int = 0

	private var items: [Item] = []
	private var search: String = ""
	private var isLoading: Bool = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ search: String) {

		super.init(nibName: nil, bundle: nil)

		self.search = search
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		navigationItem.titleView = viewTitle

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(actionSearch))

		collectionView.register(UINib(nibName: "SquaredCell", bundle: nil), forCellWithReuseIdentifier: "SquaredCell")

		let margin = Grid.gridMargin / 2
		collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

		reloadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillLayoutSubviews() {

		super.viewWillLayoutSubviews()

		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - Backend methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func reloadItems() {

		if (!isLoading) {
			page = 0
			total = 0

			scrollToZero()
			items.removeAll()
			collectionView.reloadData()

			loadItems()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadNext() {

		if (!isLoading) {
			page += 1
			loadItems()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadItems() {

		updateLoading(true)
		Backend.items(search, page) { [weak self] count, array, error in
			guard let self = self else { return }
			if let error = error {
				ProgressHUD.failed(error)
			} else if let array = array {
				total = count
				items.append(contentsOf: array)
				collectionView.reloadData()
			}
			updateLoading(false)
		}
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToZero() {

		if (collectionView.numberOfItems(inSection: 0) != 0) {
			collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLoading(_ value: Bool) {

		isLoading = value

		labelTitle.text = "\(search.capitalized)"

		labelSubtitle.text = isLoading ? "Loading..." : "\(items.count) of \(total)"
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionRandom(_ sender: Any) {

		search = Keywords.random()

		reloadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSearch() {

		let searchView = SearchView()
		searchView.delegate = self
		let navController = NavigationController(rootViewController: searchView)
		present(navController, animated: true)
	}
}

// MARK: - SearchDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: SearchDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSearchItem(_ search: String) {

		self.search = search

		reloadItems()
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return items.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

		if (indexPath.item == items.count-1) && (items.count < total) {
			loadNext()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SquaredCell", for: indexPath) as! SquaredCell

		let item = items[indexPath.item]
		cell.loadImage(item)

		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let widthCollection = collectionView.bounds.width - Grid.gridMargin
		let widthCell = widthCollection / Grid.columns()

		Grid.widthGridImage = widthCell - Grid.gridMargin

		return CGSize(width: widthCell, height: widthCell)
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredView: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let pageView = PageView(items, indexPath.item)
		navigationController?.pushViewController(pageView, animated: true)
	}
}
