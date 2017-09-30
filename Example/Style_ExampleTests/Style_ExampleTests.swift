import Style
import XCTest

class Style_ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testPerformanceExample() {
        let view = UIView()
        self.measure {
            for _ in 0 ... 10000 {
                view.style.state = 1
            }
            for _ in 0 ... 10000 {
                _ = view.style.state
            }
            for x in 0 ... 10000 {
                view.style.prepare(state: x, decoration: { (view) in
                    //
                })
            }
        }
    }
}
