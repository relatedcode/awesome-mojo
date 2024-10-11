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
class PageView: UIViewController {

	@IBOutlet private var collectionView: UICollectionView!

	private var items: [Item] = []
	private var selected: Int = 0
	private var gridView: GridView?

	private var orientation = UIInterfaceOrientation.unknown

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ items: [Item], _ selected: Int, _ gridView: GridView? = nil) {

		super.init(nibName: nil, bundle: nil)

		self.items = items
		self.selected = selected
		self.gridView = gridView
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Page"

		let image = UIImage(systemName: "icloud.and.arrow.down")
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionSave))

		collectionView.register(UINib(nibName: "PageCell1", bundle: nil), forCellWithReuseIdentifier: "PageCell1")

		orientation = interfaceOrientation()

		DispatchQueue.main.async {
			self.scrollToItem()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

		super.viewWillTransition(to: size, with: coordinator)

		let custom = (interfaceOrientation() == orientation)
		gridView?.updateTransition(custom: custom)

		scrollToItem()
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToItem() {

		collectionView.performBatchUpdates({
			collectionView.reloadData()
		}, completion: { [self] _ in
			let indexPath = IndexPath(item: selected, section: 0)
			collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
		})
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func interfaceOrientation() -> UIInterfaceOrientation {

		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
			return windowScene.interfaceOrientation
		}
		return .unknown
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSave() {

		let item = items[selected]
		let full = item.full()
		Pictures().download(full)
	}
}

// MARK: - PageViewProtocol
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView: PageViewProtocol {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageSize() -> CGSize {

		let item = items[selected]

		let widthImage = view.bounds.width - 2 * Grid.pageMargin
		let heightImage = widthImage * item.ratio

		return CGSize(width: widthImage, height: heightImage)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imageView() -> UIImageView {

		let selectedPath = IndexPath(item: selected, section: 0)
		if let pageCell1 = collectionView.cellForItem(at: selectedPath) as? PageCell1 {
			let indexPath = IndexPath(row: 0, section: 0)
			if let pageCell2 = pageCell1.tableView.cellForRow(at: indexPath) as? PageCell2 {
				return pageCell2.imagePage
			}
		}

		return UIImageView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imagePosition() -> CGPoint {

		let selectedPath = IndexPath(item: selected, section: 0)
		if let cell = collectionView.cellForItem(at: selectedPath) as? PageCell1 {
			return cell.convert(CGPoint(x: Grid.pageMargin, y: Grid.pageMargin + cell.contentOffsetY), to: view)
		}

		return collectionView.convert(CGPoint(x: Grid.pageMargin, y: Grid.pageMargin), to: view)
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		let width = collectionView.bounds.width
		let offsetX = collectionView.contentOffset.x
		selected = Int(round(offsetX / width))

		gridView?.updateSelected(selected)
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView: UICollectionViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return items.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCell1", for: indexPath) as! PageCell1

		let item = items[indexPath.item]
		cell.bindData(item, self)

		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageView: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		return collectionView.bounds.size
	}
}
