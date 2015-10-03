//
//  ChatConcurrentOperation.swift
//  ParaCon
//
//  Created by Dario Lencina on 10/3/15.
//  Copyright © 2015 dario. All rights reserved.
//

import Foundation
import ParaCon

public class ImageOperation : PCConcurrentOperation {
    public let opName : String

    init(opName : String) {
        self.opName = opName
        super.init()
    }
}

public class ImageReceiver  : ImageOperation, NSStreamDelegate {
    
    public var inputStream : Optional<NSInputStream> = Optional.None
    
    public let image : Optional<UIImage> = Optional.None
    
    override public func doWork() {
        if let inputStream = self.inputStream {
            inputStream.delegate = self
            inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            inputStream.open()
        }
    }
    
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        if (eventCode == .HasBytesAvailable) {
            
            let inputStream = aStream as! NSInputStream
            
            let bufferSizeNumber = 1000000;
            
            let myBuffer = NSMutableData(length: bufferSizeNumber)
            
            let buffer = UnsafeMutablePointer<UInt8>(myBuffer!.mutableBytes)
            
            var len = 0
            
            while (inputStream.hasBytesAvailable) {
                len = inputStream.read(buffer, maxLength: bufferSizeNumber)
            }
            
            print("receiving bytes \(len)");
            
            let image = UIImage(data: NSData(bytes: buffer, length: len))
            
            print("Hi from \(opName), I received \(image)")
            finishDoingWork()
            
        } else if (eventCode == .ErrorOccurred) {
            print("ErrorOccurred \(eventCode)")
        }
    }
}

public class ImageSender : ImageOperation {
    
    private var outputStream : Optional<NSOutputStream> =  Optional.None
    private let imageToSend : UIImage
    private let imageData : NSData
    
    public init(imageToSend : UIImage, opName : String) {
        self.imageToSend = imageToSend
        self.imageData = UIImageJPEGRepresentation(self.imageToSend, 1)!
        super.init(opName: opName)
    }
    
    override public func doWork() {
        if let outputStream = self.outputStream {
            outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            outputStream.open()
            print("wrote \(outputStream.write(UnsafePointer<UInt8>(imageData.bytes), maxLength: imageData.length))")
            finishDoingWork()
        }
    }
    
    public func sendImageTo(op : ImageReceiver) -> Void {
        NSStream.getBoundStreamsWithBufferSize(imageData.length,
            inputStream: &op.inputStream,
            outputStream: &self.outputStream)
    }
}