# Promise

##  About this project

This project starts with practice, writing a PromiseKit and hope it is simpler and easier to use on my projects. 

If you have any idea or wanna to contribute it, just have PR for it. The PR just have clear description about what you do. 

## How to use

```swift
firstly(executor: .main) {
    .init(9527)
}
.dispatch(to: .background)
.map(String.init)
.then { _ in
    .init(1000)
}
.map { _ in
    throw PromiseError.invaild
}
.dispatch(to: .main)
.catch {
    print($0)
}
```
## Features

The first following list is completed features and the second is ToDos.

### Completed

* Chainable (Fluent interface)
* Async
* Dispatch to main/background queue.

### ToDos

* [ ] Group
* [ ] Delay/After
* [ ] Support ObjC

## Reference

This project is inspired by [mxcl/PromiseKit](https://github.com/mxcl/PromiseKit)

### Others

* [Async](https://github.com/duemunk/Async)


## License

MIT License

Copyright (c) 2020 Green

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

