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
protocol GridLayoutDelegate: AnyObject {

	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GridLayout: UICollectionViewLayout {

	weak var delegate: GridLayoutDelegate!

	var widthCollection: CGFloat = 0
	var heightCollection: CGFloat = 0

	private var attributesArray: [UICollectionViewLayoutAttributes] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var collectionViewContentSize: CGSize {

		return CGSize(width: widthCollection, height: heightCollection)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepare() {

		attributesArray.removeAll()

		if let collectionView = collectionView {

			widthCollection = collectionView.bounds.width - Grid.gridMargin
			heightCollection = 0

			let widthCell = widthCollection / Grid.columns()

			var offsetX: [CGFloat] = []
			var offsetY: [CGFloat] = []

			for column in 0..<Grid.columns() {
				offsetX.append(CGFloat(column) * widthCell)
				offsetY.append(0.0)
			}

			var column = 0
			for item in 0..<collectionView.numberOfItems(inSection: 0) {

				let indexPath = IndexPath(item: item, section: 0)
				let heightCell = delegate.collectionView(collectionView, heightForCellAtIndexPath: indexPath)

				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = CGRect(x: offsetX[column], y: offsetY[column], width: widthCell, height: heightCell)
				attributesArray.append(attributes)

				offsetY[column] = offsetY[column] + heightCell

				var height = CGFloat.greatestFiniteMagnitude
				for i in 0..<Grid.columns() {
					if (offsetY[i] < height) {
						height = offsetY[i]
						column = i
					}
				}
			}

			for column in 0..<Grid.columns() {
				heightCollection = max(heightCollection, offsetY[column])
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

		var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

		for attributes in attributesArray {
			if (attributes.frame.intersects(rect)) {
				visibleLayoutAttributes.append(attributes)
			}
		}

		return visibleLayoutAttributes
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

		return attributesArray[indexPath.item]
	}
}
