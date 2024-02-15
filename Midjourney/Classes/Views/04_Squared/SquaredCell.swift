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
class SquaredCell: UICollectionViewCell {

	@IBOutlet var imageGrid: UIImageView!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageGrid.image = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let x = Grid.gridMargin / 2
		let y = Grid.gridMargin / 2

		let width = bounds.width - Grid.gridMargin
		let height = bounds.height - Grid.gridMargin

		imageGrid.frame = CGRect(x: x, y: y, width: width, height: height)

		imageGrid.layer.masksToBounds = true
		imageGrid.layer.cornerRadius = Grid.gridCorner
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SquaredCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ item: Item) {

		objectId = item.objectId

		let width = bounds.width - Grid.gridMargin
		let height = bounds.height - Grid.gridMargin

		Image.load(item.link(), width, height) { [weak self] image, error, later in
			guard let self = self else { return }
			if (objectId == item.objectId) {
				if let image = image {
					imageGrid.image = image
				} else if later {
					loadLater(item)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadLater(_ item: Item) {

		DispatchQueue.main.async(after: 0.75) { [weak self] in
			guard let self = self else { return }
			if (objectId == item.objectId) {
				if (imageGrid.image == nil) {
					loadImage(item)
				}
			}
		}
	}
}
