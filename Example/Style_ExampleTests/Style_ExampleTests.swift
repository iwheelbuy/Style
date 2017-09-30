import Style
import XCTest

class Style_ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testPerformanceExample() {
        let view = UIView()
        self.measure {
            for x in 0 ... 100000 {
                view.style.prepare(state: x, decoration: { (view) in
                    //
                })
            }
            for x in 0 ... 100000 {
                view.style.state = x
            }
        }
    }
}
