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
class PageCell1: UICollectionViewCell {

	@IBOutlet var tableView: UITableView!

	private var item: Item!
	private var pageView: PageView!

	var contentOffsetY: CGFloat = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func awakeFromNib() {

		tableView.register(UINib(nibName: "PageCell2", bundle: nil), forCellReuseIdentifier: "PageCell2")

		tableView.dataSource = self
		tableView.delegate = self

		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		tableView.setContentOffset(CGPoint.zero, animated: false)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ item: Item, _ pageView: PageView) {

		self.item = item
		self.pageView = pageView

		tableView.reloadData()
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageCell1: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		contentOffsetY = -scrollView.contentOffset.y

		if (scrollView.contentOffset.y < -70) {
			pageView.navigationController?.popViewController(animated: true)
		}
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageCell1: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 2
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.row == 0) {
			let widthImage = bounds.width - 2 * Grid.pageMargin
			let heightImage = widthImage * item.ratio
			let heightCell = heightImage + 2 * Grid.pageMargin
			return heightCell
		}

		if (indexPath.row == 1) {
			let label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width-30, height: 0))
			label.text = item.prompt
			label.font = Grid.pageTextFont
			label.numberOfLines = 0
			label.sizeToFit()
			return label.frame.height + 15
		}

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.row == 0) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell2", for: indexPath) as! PageCell2
			cell.selectionStyle = .none
			cell.loadImage(item)
			return cell
		}

		if (indexPath.row == 1) {
			var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellText")
			if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cellText") }
			cell.textLabel?.text = item.prompt
			cell.textLabel?.font = Grid.pageTextFont
			cell.textLabel?.numberOfLines = 0
			return cell
		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PageCell1: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.row == 0) {
			if let path = Image.path(link: item.link()) {
				if let image = UIImage(path: path) {
					let object = PhotoObject(item.objectId, image)
					let photoController = PhotoController([object], 0)
					pageView.present(photoController, animated: true)
				}
			}
		}
		if (indexPath.row == 1) {
			UIPasteboard.general.string = item.prompt
			ProgressHUD.succeed("Copied.")
		}
	}
}
