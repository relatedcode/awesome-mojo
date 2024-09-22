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
class Item {

	var objectId: String = ""
	var prompt: String = ""
	var ratio: Double = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ values: [String: Any]) {

		objectId = values["objectId"] as? String ?? ""
		prompt = values["prompt"] as? String ?? ""
		ratio = values["ratio"] as? Double ?? 0.0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func link() -> String {

		return "https://cdn.midjourney.com/" + objectId + "_384_N.webp"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func full() -> String {

		return "https://cdn.midjourney.com/" + objectId + ".png"
	}
}
