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
class Backend {

	static let baseUrl = "https://appsearch.rest"

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func search(_ text: String, _ completion: @escaping ([String]?, Error?) -> Void) {

		guard let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(nil, NSError("Encode error."))
			return
		}

		guard let url = URL(string: "\(baseUrl)/search?query=\(encoded)&limit=10") else {
			completion(nil, NSError("URL error."))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			DispatchQueue.main.async {
				if (error == nil) {
					searchParse(data, completion)
				} else {
					completion(nil, error)
				}
			}
		}

		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func searchParse(_ data: Data?, _ completion: @escaping ([String]?, Error?) -> Void) {

		guard let data = data else {
			completion(nil, NSError("Missing data."))
			return
		}

		guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
			completion(nil, NSError("JSON error."))
			return
		}

		if let message = json["error"] as? String {
			completion(nil, NSError(message))
			return
		}

		guard let array = json["suggestions"] as? [String] else {
			completion(nil, NSError("Result error."))
			return
		}

		completion(array, nil)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func items(_ text: String, _ page: Int, _ completion: @escaping (Int, [Item]?, Error?) -> Void) {

		guard let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			completion(0, nil, NSError("Encode error."))
			return
		}

		guard let url = URL(string: "\(baseUrl)/items?query=\(encoded)&page=\(page)&limit=100") else {
			completion(0, nil, NSError("URL error."))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			DispatchQueue.main.async {
				if (error == nil) {
					itemsParse(data, completion)
				} else {
					completion(0, nil, error)
				}
			}
		}

		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func itemsParse(_ data: Data?, _ completion: @escaping (Int, [Item]?, Error?) -> Void) {

		guard let data = data else {
			completion(0, nil, NSError("Missing data."))
			return
		}

		guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
			completion(0, nil, NSError("JSON error."))
			return
		}

		guard let array = json["data"] as? [[String: Any]] else {
			completion(0, nil, NSError("Result error."))
			return
		}

		let total = json["total"] as? Int ?? 0

		var items: [Item] = []
		for values in array {
			let item = Item(values)
			items.append(item)
		}

		items.shuffle()

		completion(total, items, nil)
	}
}
