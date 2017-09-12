import Style
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let view1 = UIView()
                view1.style.prepare(state: 17, decoration: UIView.decoration(closure: { (view) in
                    //
                }))
                let view2 = UIView()
                view2.style.prepare(state: 12, decoration: UIView.decoration(closure: { (view) in
                    //
                }))
            }
        }
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

