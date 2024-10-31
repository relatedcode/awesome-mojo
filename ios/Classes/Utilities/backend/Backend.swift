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

	static let baseUrl = "https://appsearch.cloud"

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
				if let error = check(data, response, error) {
					completion(nil, error)
				} else {
					searchParse(data, completion)
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
				if let error = check(data, response, error) {
					completion(0, nil, error)
				} else {
					itemsParse(data, completion)
				}
			}
		}

		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func itemsParse(_ data: Data?, _ completion: @escaping (Int, [Item]?, Error?) -> Void) {

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

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func random(_ completion: @escaping (String?, Error?) -> Void) {

		guard let url = URL(string: "\(baseUrl)/random") else {
			completion(nil, NSError("URL error."))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			DispatchQueue.main.async {
				if let error = check(data, response, error) {
					completion(nil, error)
				} else {
					randomParse(data, completion)
				}
			}
		}

		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func randomParse(_ data: Data?, _ completion: @escaping (String?, Error?) -> Void) {

		guard let data = data else {
			completion(nil, NSError("Missing data."))
			return
		}

		guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
			completion(nil, NSError("JSON error."))
			return
		}

		guard let word = json["word"] as? String else {
			completion(nil, NSError("Result error."))
			return
		}

		completion(word, nil)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func check(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Error? {

		if let error = error {
			return error
		}

		if let httpResponse = response as? HTTPURLResponse {
			if (200...299).contains(httpResponse.statusCode) {
				return nil
			}
		}

		if let data = data, let message = String(data: data, encoding: .utf8) {
			return NSError(message)
		}

		return NSError("Unknown error")
	}
}
