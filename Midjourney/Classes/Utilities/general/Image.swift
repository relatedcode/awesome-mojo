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
struct Size {

	var width: Int
	var height: Int

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ size: CGFloat) {

		self.width = Int(size)
		self.height = Int(size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ frame: CGRect) {

		self.width = Int(frame.size.width)
		self.height = Int(frame.size.height)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ width: CGFloat, _ height: CGFloat) {

		self.width = Int(width)
		self.height = Int(height)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Counter {

	private static var array: [String] = []

	private static let queue = DispatchQueue(label: UUID().uuidString)

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func add(_ photoId: String) {

		queue.async {
			array.appendUnique(photoId)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func del(_ photoId: String) {

		queue.async {
			array.remove(photoId)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func check(_ photoId: String) -> Bool {

		queue.sync {
			return array.contains(photoId)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func value() -> Int {

		queue.sync {
			return array.count
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Image {

	private static let photos = NSCache<NSString, UIImage>()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func cache(_ photoId: String, _ image: UIImage) {

		photos.setObject(image, forKey: key(photoId))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func cache(_ photoId: String, _ size: Size, _ image: UIImage) {

		photos.setObject(image, forKey: key(photoId, size))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func cache(_ photoId: String, _ size: Size? = nil) -> UIImage? {

		return photos.object(forKey: key(photoId, size))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func key(_ photoId: String, _ size: Size? = nil) -> NSString {

		return NSString(string: name(photoId, size))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func name(_ photoId: String, _ size: Size? = nil) -> String {

		if let size = size {
			return "\(photoId)-\(size.width)-\(size.height)"
		}
		return "\(photoId)"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func succeed(_ image: UIImage, _ completion: @escaping (UIImage?, Error?) -> Void) {

		DispatchQueue.main.async {
			completion(image, nil)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func failed(_ text: String, _ completion: @escaping (UIImage?, Error?) -> Void) {

		DispatchQueue.main.async {
			completion(nil, NSError(text))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func failed(_ error: Error, _ completion: @escaping (UIImage?, Error?) -> Void) {

		DispatchQueue.main.async {
			completion(nil, error)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func succeed(_ image: UIImage, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		DispatchQueue.main.async {
			completion(image, nil, false)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func failed(_ text: String, _ later: Bool, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		DispatchQueue.main.async {
			completion(nil, NSError(text), later)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func failed(_ error: Error, _ later: Bool, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		DispatchQueue.main.async {
			completion(nil, error, later)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func load(_ link: String, _ completion: @escaping (UIImage?, Error?) -> Void) {

		let photoId = link.md5()

		if let image = cache(photoId) {
			completion(image, nil)
			return
		}

		DispatchQueue.global(qos: .userInteractive).async {
			if let path = path(photoId) {
				if let image = UIImage(path: path) {
					cache(photoId, image)
					succeed(image, completion)
				} else {
					File.remove(path)
					download(link, photoId, completion)
				}
			} else {
				download(link, photoId, completion)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func download(_ link: String, _ photoId: String, _ completion: @escaping (UIImage?, Error?) -> Void) {

		guard let url = URL(string: link) else {
			failed("Link error.", completion)
			return
		}

		if (Counter.check(photoId)) {
			failed("Download in progress.", completion)
		} else {
			Counter.add(photoId)
			let task = URLSession.shared.dataTask(with: url) { data, response, error in
				Counter.del(photoId)

				if let error = error {
					failed(error, completion)
				} else {
					if let data = data, let image = UIImage(data: data) {
						save(photoId, image)
						cache(photoId, image)
						succeed(image, completion)
					} else {
						failed("Download error.", completion)
					}
				}
			}

			task.resume()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func load(_ link: String, _ size: CGFloat, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		load(link, Size(size), completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func load(_ link: String, _ frame: CGRect, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		load(link, Size(frame), completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func load(_ link: String, _ width: CGFloat, _ height: CGFloat, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		load(link, Size(width, height), completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func load(_ link: String, _ size: Size, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		let photoId = link.md5()

		if let image = cache(photoId, size) {
			completion(image, nil, false)
			return
		}

		DispatchQueue.global(qos: .userInteractive).async {
			if let path = path(photoId, size) {
				if let image = UIImage(path: path) {
					cache(photoId, size, image)
					succeed(image, completion)
				} else {
					File.remove(path)
					check(link, photoId, size, completion)
				}
			} else {
				check(link, photoId, size, completion)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func check(_ link: String, _ photoId: String, _ size: Size, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		if let path = path(photoId) {
			if let full = UIImage(path: path) {
				let image = resize(full, size)
				save(photoId, size, image)
				cache(photoId, size, image)
				succeed(image, completion)
			} else {
				File.remove(path)
				download(link, photoId, size, completion)
			}
		} else {
			download(link, photoId, size, completion)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func download(_ link: String, _ photoId: String, _ size: Size, _ completion: @escaping (UIImage?, Error?, Bool) -> Void) {

		guard let url = URL(string: link) else {
			failed("Link error.", false, completion)
			return
		}

		if (Counter.value() > 5) {
			failed("Too many processes.", true, completion)
		} else if (Counter.check(photoId)) {
			failed("Download in progress.", true, completion)
		} else {
			Counter.add(photoId)
			let task = URLSession.shared.dataTask(with: url) { data, response, error in
				Counter.del(photoId)

				if let error = error {
					failed(error, false, completion)
				} else {
					if let data = data, let full = UIImage(data: data) {
						let image = resize(full, size)
						save(photoId, full)
						save(photoId, size, image)
						cache(photoId, size, image)
						succeed(image, completion)
					} else {
						failed("Download error.", false, completion)
					}
				}
			}

			task.resume()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func save(_ photoId: String, _ image: UIImage) {

		save(photoId, nil, image)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func save(_ photoId: String, _ size: Size?, _ image: UIImage) {

		DispatchQueue.global(qos: .background).async {
			if let data = image.pngData() {
				let path = xpath(photoId, size)
				let temp = URL(fileURLWithPath: path)
				try? data.write(to: temp, options: .atomic)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func resize(_ image: UIImage, _ size: Size) -> UIImage {

		return image.resize(width: size.width, height: size.height)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func path(link: String, _ size: Size? = nil) -> String? {

		let photoId = link.md5()

		return path(photoId, size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(_ photoId: String, _ size: Size? = nil) -> String? {

		let path = xpath(photoId, size)

		return File.exist(path) ? path : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func xpath(_ photoId: String, _ size: Size?) -> String {

		let file = name(photoId, size) + ".png"

		return Dir.document("images", and: file)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func delete(link: String, _ size: Size? = nil) {

		let photoId = link.md5()

		delete(photoId, size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func delete(_ photoId: String, _ size: Size?) {

		let path = xpath(photoId, size)

		File.remove(path)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Image {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupFiles(_ extensions: [String] = ["jpg", "png", "mp4", "m4a"]) {

		var isDir: ObjCBool = false

		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						File.remove(path)
					}
				}
			}
		}
	}
}
