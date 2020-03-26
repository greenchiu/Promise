import Foundation
import Promise

let p = Promise(1)

p.then { _ in
    .init("!")
}
.done {
    print($0)
}
.catch {
    print($0)
}
