//: # Swift Context manager: Implementing Python Context manager in swift
//: Playground to demonstrage how to implement a pythonic context manager in swift
//: Read more:
//:  - [Python context manager](http://preshing.com/20110920/the-python-with-statement-by-example/)
//:  - [Article realted to this playground](https://medium.com/@NSomar/swift-context-manager-implementing-python-context-manager-in-swift-f327b2b4a7d7)

import UIKit

protocol Context {
  func enter()
  func exit(error: ErrorType?)
}

func with<C: Context>(context: C?, block:(context: C) throws -> () ) {
  guard let context = context else { return }
  
  context.enter()
  
  do {
    try block(context: context)
    context.exit(nil)
  } catch {
    context.exit(error)
  }
}


//: ## NSFileHandle context manager

let f = NSFileHandle(forReadingAtPath: NSBundle.mainBundle().pathForResource("test", ofType: "")!)!
NSString(data: f.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
f.closeFile()

struct FileHandleContext: Context {
  var fileHandle: NSFileHandle!
  
  init(filePath: String) {
    let file = NSBundle.mainBundle().pathForResource("test", ofType: "")!
    fileHandle = NSFileHandle(forReadingAtPath: file)
  }
  
  func enter() {
    //nothing
  }
  
  func exit(error: ErrorType?) {
    fileHandle.closeFile()
  }
}

let file = NSBundle.mainBundle().pathForResource("test", ofType: "")!
with(FileHandleContext(filePath: file)) { (context) -> () in
  let s = NSString(data: context.fileHandle.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
}

//: Throwing exceptions inside `with` will be captured by with and forwared to `exit` method of `FileHandleContext`

with(FileHandleContext(filePath: file)) { (context) -> () in
  throw NSError(domain: "", code: 0, userInfo: nil)
}

//: ## NSUserDefaults context manager

class UserDefaultsSaver: Context {
  
  var userDefaults: NSUserDefaults!
  
  func enter() {
    userDefaults = NSUserDefaults()
  }
  
  func exit(error: ErrorType?) {
    userDefaults.synchronize()
  }
  
  func write(key key: String, value: AnyObject?) {
    userDefaults.setValue(value, forKey: key)
  }
  
}


with(UserDefaultsSaver()) { (context) -> () in
  context.write(key: "SomeKey1", value: "SomeValue1")
  context.write(key: "SomeKey2", value: "SomeValue2")
}

//: ## Bonus, NSUserDefaults extension Context conformance

extension NSUserDefaults: Context {
  
  func enter() {
    //Do nothing
  }
  
  func exit(error: ErrorType?) {
    synchronize()
  }
  
  func write(key key: String, value: AnyObject?) {
    setValue(value, forKey: key)
  }
  
}


with(NSUserDefaults()) { (context) -> () in
  context.setValue("SomeValue1", forKey: "SomeKey1")
  context.setValue("SomeValue2", forKey: "SomeKey2")
}

//: Author:    
//: Omar Abdelhafith    
//: [@ifnottrue](https://twitter.com/ifnottrue), [o.arrabi@me.com](o.arrabi@me.com)
