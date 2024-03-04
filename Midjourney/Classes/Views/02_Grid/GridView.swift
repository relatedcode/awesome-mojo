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
class GridView: UIViewController {

	@IBOutlet private var viewTitle: UIView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var labelSubtitle: UILabel!

	@IBOutlet private var collectionView: UICollectionView!

	private var selectedPath = IndexPath(item: 0, section: 0)
	private let delegateHolder = NavigationControllerDelegate()

	private var gridLayout: GridLayout!

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

		collectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")

		gridLayout = GridLayout()
		gridLayout.delegate = self
		collectionView.collectionViewLayout = gridLayout

		let margin = Grid.gridMargin / 2
		collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

		reloadItems()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		navigationController?.delegate = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillLayoutSubviews() {

		super.viewWillLayoutSubviews()

		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - Backend methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView {

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
extension GridView {

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
extension GridView {

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
extension GridView: SearchDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSearchItem(_ search: String) {

		self.search = search

		reloadItems()
	}
}

// MARK: - Updating methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateSelected(_ selected: Int) {

		selectedPath = IndexPath(item: selected, section: 0)
		collectionView.scrollToItem(at: selectedPath, at: .top, animated: false)

		collectionView.setNeedsLayout()
		collectionView.layoutIfNeeded()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateTransition(custom: Bool) {

		navigationController?.delegate = custom ? delegateHolder : nil
	}
}

// MARK: - GridViewProtocol
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: GridViewProtocol {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageSize() -> CGSize {

		let item = items[selectedPath.item]

		let widthCollection = gridLayout.widthCollection
		let widthCell = widthCollection / Grid.columns()
		let widthImage = widthCell - Grid.gridMargin
		let heightImage = widthImage * item.ratio

		return CGSize(width: widthImage, height: heightImage)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageView() -> UIImageView {

		if let cell = collectionView.cellForItem(at: selectedPath) as? GridCell {
			if let imageGrid = cell.imageGrid {
				let imageView = UIImageView(frame: imageGrid.frame)
				imageView.image = imageGrid.image
				imageView.layer.masksToBounds = true
				imageView.layer.cornerRadius = Grid.gridCorner
				imageView.backgroundColor = imageGrid.backgroundColor
				return imageView
			}
		}

		return UIImageView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imagePosition() -> CGPoint {

		if let cell = collectionView.cellForItem(at: selectedPath) as? GridCell {
			return cell.convert(cell.imageGrid.frame.origin, to: view)
		}

		return CGPoint.zero
	}
}

// MARK: - GridLayoutDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: GridLayoutDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {

		let item = items[indexPath.item]

		let widthCollection = gridLayout.widthCollection
		let widthCell = widthCollection / Grid.columns()
		let widthImage = widthCell - Grid.gridMargin
		let heightImage = widthImage * item.ratio
		let heightCell = heightImage + Grid.gridMargin

		Grid.widthGridImage = widthImage

		return heightCell
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: UICollectionViewDataSource {

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

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell

		let item = items[indexPath.item]
		cell.loadImage(item)

		return cell
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GridView: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		selectedPath = indexPath

		let pageView = PageView(items, indexPath.item, self)
		navigationController?.delegate = delegateHolder
		navigationController?.pushViewController(pageView, animated: true)
	}
}
