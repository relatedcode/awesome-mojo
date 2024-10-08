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

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Keywords {

	private var words: [String: Int] = [:]

	static let shared = Keywords()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		shared.load()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Keywords {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func load() {

		let path = Dir.application("words.json")

		if let data = Data(path: path) {
			decode(data)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func decode(_ data: Data) {

		if let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
			words = dict
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Keywords {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func random() -> String {

		if let element = shared.words.randomElement() {
			return element.key
		}
		return ""
	}
}
