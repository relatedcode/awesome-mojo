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
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		Keywords.setup()

		applicationFolder()

		window = UIWindow(frame: UIScreen.main.bounds)

		let mainView = MainView(nibName: "MainView", bundle: nil)
		let navController = NavigationController(rootViewController: mainView)

		window?.rootViewController = navController
		window?.makeKeyAndVisible()

		if #available(iOS 15.0, *) {
			UITableView.appearance().sectionHeaderTopPadding = 0
		}

		ProgressHUD.colorAnimation = AppColor.main
		ProgressHUD.colorProgress = AppColor.main

		return true
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {

	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationFolder() {

		if let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
			if let temp = document.components(separatedBy: "/Library/Developer/CoreSimulator/Devices/").last {
				let array = temp.components(separatedBy: "/data/Containers/Data/Application/")
				if let device = array.first, var app = array.last {
					app = app.replacingOccurrences(of: "/Documents", with: "")
					print("Device: \(device) - App: \(app)")
				}
			}
		}
	}
}
