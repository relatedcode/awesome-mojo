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
class Pictures: NSObject {

	static var downloading = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func download(_ link: String) {

		if (Pictures.downloading) { return }
		else { Pictures.downloading = true }

		ProgressHUD.progress(0.0, interaction: true)

		guard let url = URL(string: link) else { fatalError() }

		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		let task = session.downloadTask(with: url)

		task.resume()
	}
}

// MARK: - URLSessionDownloadDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Pictures: URLSessionDownloadDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

		let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)

		ProgressHUD.progress(progress, interaction: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

		Pictures.downloading = false

		if let error = error {
			ProgressHUD.failed(error)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

		ProgressHUD.progress(1.0, interaction: true)

		if let data = Data(path: location.relativePath) {
			if let image = UIImage(data: data) {
				UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
			}
		}
	}
}

// MARK: -
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Pictures {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

		Pictures.downloading = false

		if let error = error {
			ProgressHUD.failed(error)
		} else {
			ProgressHUD.succeed()
		}
	}
}
