//
//  ConcurrentOperation.swift
//  ParaCon
//
//  Created by Dario Lencina on 10/3/15.
//  Copyright © 2015 dario. All rights reserved.
//

import Foundation

public class PCConcurrentOperation : NSOperation {
    
    var _isExecuting : Bool = false {
        willSet {self.willChangeValueForKey("isExecuting")}
        didSet {
            self.didChangeValueForKey("isExecuting")
        }
    }
    
    override public var executing: Bool {
        get { return _isExecuting}
    }
    
    var _isFinished : Bool = false {
        willSet {self.willChangeValueForKey("isFinished")}
        didSet {self.didChangeValueForKey("isFinished")}
    }
    
    override public var finished: Bool {
        get { return _isFinished}
    }
    
    private let _requiresRunLoop : Bool = true;
    private var _keepAliveTimer : NSTimer;
    private var _stopRunLoop : Bool = false;
    
    override public var asynchronous: Bool {
        get{return true}
    }
    
    override public init() {
        _keepAliveTimer = NSTimer.init()
        super.init()
    }
    
    public override func start() -> Void {
        print("beginning \(self.debugDescription)")
        self._isExecuting = true
        if(_requiresRunLoop) {
            let runLoop = NSRunLoop.currentRunLoop()
            _keepAliveTimer = NSTimer.init(timeInterval: Double(CGFloat.max), target: self, selector: "timeout:", userInfo: nil, repeats: false)
            runLoop.addTimer(_keepAliveTimer, forMode:NSDefaultRunLoopMode)
            self.doWork()
            let updateInterval : NSTimeInterval = 0.1
            var loopUntil : NSDate = NSDate(timeIntervalSinceNow : updateInterval)
            while(!_stopRunLoop && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: loopUntil)) {
                loopUntil = loopUntil.dateByAddingTimeInterval(updateInterval)
            }
            print("bye from \(self.debugDescription)")
        } else {
            self.doWork()
        }
    }
    
    public func doWork() -> Void {
        print("Subclasses must override this method")
    }
    
    func timeout(timer : NSTimer){
        // this method should never get called.
        self.finishDoingWork()
    }
    
    public func finishDoingWork() -> Void {
        if _requiresRunLoop {
            _keepAliveTimer.invalidate()
            _stopRunLoop = true
        }
        self.finish()
        
    }
    func finish() -> Void {
        self._isExecuting = false
        self._isFinished = true
        print("finishing \(self.debugDescription)")
    }
}