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
class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

		let transition = Transition()
		transition.operation = operation
		return transition
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Transition: NSObject, UIViewControllerAnimatedTransitioning {

	let animationDuration = 0.4

	var operation = UINavigationController.Operation.none

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

		return animationDuration
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

		if (operation == .push)	{ animateTransitionPush(using: transitionContext)	}
		if (operation == .pop)	{ animateTransitionPop(using: transitionContext)	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func animateTransitionPush(using transitionContext: UIViewControllerContextTransitioning) {

		if let gridView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? GridViewProtocol {
			if let pageView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PageViewProtocol {

				if let viewGrid = gridView.view, let viewPage = pageView.view {

					let containerView = transitionContext.containerView
					containerView.backgroundColor = UIColor.systemBackground
					containerView.addSubview(viewPage)

					let imageSizeGrid		= gridView.imageSize()
					let imageSizePage		= pageView.imageSize()
					let imageViewGrid		= gridView.imageView()
					let imagePositionGrid	= gridView.imagePosition()
					let imagePositionPage	= pageView.imagePosition()

					let scaleX = imageSizePage.width / imageSizeGrid.width
					let scaleY = imageSizePage.height / imageSizeGrid.height

					imageViewGrid.frame.origin = imagePositionGrid
					containerView.addSubview(imageViewGrid)

					viewPage.alpha = 0

					UIView.animate(withDuration: animationDuration, animations: {

						imageViewGrid.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
						imageViewGrid.frame.origin = imagePositionPage

						viewGrid.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
						viewGrid.frame.origin.x = -imagePositionGrid.x * scaleX + imagePositionPage.x
						viewGrid.frame.origin.y = -imagePositionGrid.y * scaleY + imagePositionPage.y
						viewGrid.alpha = 0

					}, completion: { finished in
						if (finished) {
							imageViewGrid.removeFromSuperview()
							viewGrid.transform = CGAffineTransform.identity
							viewGrid.alpha = 1
							viewPage.alpha = 1
							transitionContext.completeTransition(true)
						}
					})
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func animateTransitionPop(using transitionContext: UIViewControllerContextTransitioning) {

		if let pageView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? PageViewProtocol {
			if let gridView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? GridViewProtocol {

				if let viewPage = pageView.view, let viewGrid = gridView.view {

					let containerView = transitionContext.containerView
					containerView.backgroundColor = UIColor.systemBackground
					containerView.addSubview(viewGrid)

					let imageSizeGrid		= gridView.imageSize()
					let imageSizePage		= pageView.imageSize()
					let imageViewPage		= pageView.imageView()
					let imagePositionGrid	= gridView.imagePosition()
					let imagePositionPage	= pageView.imagePosition()

					let scaleX = imageSizePage.width / imageSizeGrid.width
					let scaleY = imageSizePage.height / imageSizeGrid.height

					imageViewPage.frame.origin = imagePositionPage
					containerView.addSubview(imageViewPage)

					viewGrid.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
					viewGrid.frame.origin.x = -imagePositionGrid.x * scaleX + imagePositionPage.x
					viewGrid.frame.origin.y = -imagePositionGrid.y * scaleY + imagePositionPage.y
					viewGrid.alpha = 0
					viewPage.alpha = 0

					UIView.animate(withDuration: animationDuration, animations: {

						imageViewPage.transform = CGAffineTransform(scaleX: 1/scaleX, y: 1/scaleY)
						imageViewPage.frame.origin = imagePositionGrid

						viewGrid.transform = CGAffineTransform.identity
						viewGrid.frame.origin = CGPoint.zero
						viewGrid.alpha = 1

					}, completion:{ finished in
						if (finished) {
							imageViewPage.removeFromSuperview()
							transitionContext.completeTransition(true)
						}
					})
				}
			}
		}
	}
}
