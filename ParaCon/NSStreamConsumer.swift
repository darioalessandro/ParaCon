//
//  NSStreamConsumer.swift
//  ParaCon
//
//  Created by Dario Lencina on 10/3/15.
//  Copyright © 2015 dario. All rights reserved.
//

import Foundation

public class NSStreamConsumer : PCConcurrentOperation, NSStreamDelegate {
    
    private let stream : NSStream
    
    private let foundElement : (NSData) -> (Void)
    
    public init (stream : NSStream, foundElement : (NSData) -> (Void)) {
        self.stream = stream
        self.foundElement = foundElement
        super.init()
    }
    
    public func write(data : NSData) -> Int {
        let output = self.stream as! NSOutputStream
        let ptr = UnsafePointer<UInt8>(data.bytes)
        var i = 0;
        while(i < data.length && _isExecuting && !_isFinished) {
            i = i + output.write(ptr, maxLength: data.length)
        }
        return i
    }
    
    override public func doWork() {
        self.stream.delegate = self
        self.stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.stream.open()
    }
    
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode {
            case NSStreamEvent.HasBytesAvailable:
                let inputStream = aStream as! NSInputStream
                let bufferSizeNumber = 1000000;
                let myBuffer = NSMutableData(length: bufferSizeNumber)
                let buffer = UnsafeMutablePointer<UInt8>(myBuffer!.mutableBytes)
                var len = 0
                
                while (inputStream.hasBytesAvailable) {
                    len = len + inputStream.read(buffer, maxLength: bufferSizeNumber)
                }
                print("receiving bytes \(len)");
                self.foundElement(NSData(bytes: buffer, length: len))
                break

            case NSStreamEvent.HasSpaceAvailable:
                print("Has Space Available")
                break
            case NSStreamEvent.OpenCompleted:
                print("Open Completed")
                break

            default:
                print("ErrorOccurred \(eventCode)")
                finishDoingWork()
        }
    }
}