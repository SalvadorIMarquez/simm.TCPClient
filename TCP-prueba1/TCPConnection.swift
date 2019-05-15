//
//  TCPConnection.swift
//  TCP-prueba1
//
//  Created by Salvador Marquez on 5/14/19.
//  Copyright © 2019 Citsa Digital. All rights reserved.
//

import Foundation
import FGRoute

protocol TCPConnectionDelegate: class{
    func receivedData(message: String)
}
class TCPConnection: NSObject{
    var  inputStream : InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096
    
    weak var delegate: TCPConnectionDelegate?
    
    func setupTCPCommunication()->Int{
        let direccion = FGRoute.getGatewayIP()
        if direccion != nil{
            var readStream: Unmanaged<CFReadStream>?
            var writeStream: Unmanaged<CFWriteStream>?
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, direccion! as CFString, 5200, &readStream, &writeStream)
            inputStream = readStream!.takeRetainedValue()
            outputStream = writeStream!.takeRetainedValue()
            inputStream.delegate = self
            inputStream.schedule(in: .current, forMode: .common)
            outputStream.schedule(in: .current, forMode:.common)
            inputStream.open()
            outputStream.open()
            return 1
        }
        return 0
    }
    
    func sendData(data: String){
        let mensaje = data.data(using: .ascii)!
        _ = mensaje.withUnsafeBytes{outputStream.write($0, maxLength: mensaje.count)}
    }
    
}

extension TCPConnection: StreamDelegate{
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("New message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            print("new message received")
            stopConection()
        case Stream.Event.errorOccurred:
            print("Error ocurred")
        case Stream.Event.hasSpaceAvailable:
            print("Has space available")
        default:
            print("Some other event...")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream){
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError{
                    break
                }
            }
            if let message = processedMessageStrinf(buffer: buffer, length: numberOfBytesRead ){
                delegate?.receivedData(message: message)
            }
        }
        
    }
    
    private func processedMessageStrinf(buffer: UnsafeMutablePointer<UInt8>, length: Int)-> String?{
        guard let mensaje = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding:  .ascii,
                                       freeWhenDone: true) else{
                return nil
        }
        return mensaje
    }
    
    func stopConection(){
        inputStream.close()
        outputStream.close()
    }
    
    
}

