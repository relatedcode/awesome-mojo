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
class Grid {

	static var gridColumns: Int = 3

	static var gridMargin: CGFloat = 5.0
	static var pageMargin: CGFloat = 10.0
	static var gridCorner: CGFloat = 5.0

	static var widthGridImage: CGFloat = 0.0

	static var pageTitleFont = UIFont.systemFont(ofSize: 17.0, weight: .bold)
	static var pageTextFont = UIFont.systemFont(ofSize: 15.0, weight: .light)

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func columns() -> Int {

		return gridColumns
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func columns() -> CGFloat {

		return CGFloat(gridColumns)
	}
}
