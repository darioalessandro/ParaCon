//
//  ParaConTests.swift
//  ParaConTests
//
//  Created by Dario Lencina on 10/3/15.
//  Copyright © 2015 dario. All rights reserved.
//

import XCTest
@testable import ParaCon

class ParaConTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImageSender() {
        var expectation = expectationWithDescription("Swift Expectations")
        let bundle : NSBundle = NSBundle(forClass:object_getClass(ImageSender))
        let path = bundle.pathForResource("jocker", ofType: "jpg")!
        let image : UIImage = UIImage(contentsOfFile: path)!
        let source = ImageSender(imageToSend: image, opName : "source")
        let destination = ImageReceiver(opName : "destination")
        source.sendImageTo(destination)
        let opQueue = NSOperationQueue()
        
        opQueue.addOperations([source,destination], waitUntilFinished: false)
        opQueue.addObserver(self, forKeyPath: "operations", options: NSKeyValueObservingOptions.New, context: &expectation)
        
        destination.completionBlock = {
            XCTAssertEqual(destination.image?.size, image.size, "Found Image")
        }

        waitForExpectationsWithTimeout(10) { (error) -> Void in
            print("error \(error)")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath! == "operations") {
            let expectation = UnsafeMutablePointer<XCTestExpectation>(context)
            let opQueue = object as! NSOperationQueue
            if opQueue.operationCount == 0 {
                expectation.memory.fulfill()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}
