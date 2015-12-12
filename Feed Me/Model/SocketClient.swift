//
//  SocketCoordsClient.swift
//  Feed Me
//
//  Created by Evgeney on 12/7/15.
//  Copyright © 2015 Ron Kliffer. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
var myself: SocketClient!

protocol SocketClientProtocol {
  func didFinishReading(data: String)
}

class SocketClient : NSObject, GCDAsyncSocketDelegate {
  var socket: GCDAsyncSocket!
  let host: String
  let port: UInt16
  var connected = false;
  var callback: SocketClientProtocol?
  

  init(host: String, port: UInt16) {
    self.host = host
    self.port = port
    super.init()
    myself = self    
  }
  
  func connect() {
    socket = GCDAsyncSocket(delegate: self, delegateQueue: /*dispatch_get_main_queue()*/
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    do {
      try socket!.connectToHost(host, onPort: port)
      print("Connecting")
    } catch {
      print("Error")
    }
  }
  
  func writeData(stringData: String) {
    let data = stringData.dataUsingEncoding(NSUTF8StringEncoding)
    socket.writeData(data, withTimeout: -1, tag: 0)
  }
  
  func socket(sock: GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
    print("Connected to \(host) on port \(p).")
    connected = true;
    socket.readDataWithTimeout(-1, tag: 0)
  
  }
  
  
  func socket(sock: GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int){
    print("Data received")
    print("Length: ", data.length)
    let datastring = NSString(data: data, encoding:NSUTF8StringEncoding) as! String
    print(datastring)
    if (datastring.containsString("\n")) {
      dispatch_async(dispatch_get_main_queue()) {
        self.callback?.didFinishReading(datastring.substringToIndex(datastring.endIndex.predecessor()))
      }
    }
    socket.readDataWithTimeout(-1, tag: 0)
  }
  /*func socket(sock: GCDAsyncSocket!,  didWriteDataWithTag tag: Int) {
    let Recieved: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
    print(Recieved)
  }*/
  
  
  
  
}
