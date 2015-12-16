//
//  SocketCoordsClient.swift
//  Feed Me
//
//  Created by Evgeney on 12/7/15.
//  Copyright © 2015 Ron Kliffer. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

protocol SocketClientProtocol {
  func didFinishReading(data: String)
  func didSocketDisconnected(data: String)
}

class SocketClient {
  let host: String
  let port: UInt16
  let connectParams: [String: [String: String]]
  let socket: SocketIOClient
  var connected = false;
  var driverCallback: SocketClientProtocol?
  var passengerCallback : SocketClientProtocol?
  
  static var clientInstance : SocketClient!
  
  static func instance() -> SocketClient {
    if (clientInstance == nil) {
      clientInstance = SocketClient(host: "localhost", port: 80, connectParams: [:])
    }
    return clientInstance
  }

  init(host: String, port: UInt16, connectParams: [String: [String:String]]) {
    self.host = host
    self.port = port
    self.connectParams = connectParams
   /* print(self.connectParams)
    do {
    var vv = connectParams["userInfo"]!
    var datastring = NSString(data: connectParams["userInfo"]!, encoding: NSUTF8StringEncoding)
    let json = try NSJSONSerialization.JSONObjectWithData(datastring!.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
      print(json)
    } catch {
      
    }*/
    
    self.socket = SocketIOClient(socketURL: host + ":" + String(port),
      options: [.Log(true), .ForcePolling(true), .ConnectParams(connectParams)])
  }
  
  func connect() {
    self.addHandlers()
    self.socket.connect()
  }
  
  func addHandlers() {
    socket.on("connect") {data, ack in
      print("socket connected, ack: ", ack)
    }
    
    socket.on("broadcast") {data, ack in
      self.driverCallback?.didFinishReading(data[0] as! String)
      self.passengerCallback?.didFinishReading(data[0] as! String)
    }
    
    socket.on("disconnect") {data, ack in
      self.driverCallback?.didSocketDisconnected(data[0] as! String)
      self.passengerCallback?.didSocketDisconnected(data[0] as! String)
    }
  }
  
  func write(coordinate: CLLocationCoordinate2D) {
    let arr = ["from_type" : "driver", "lat" : coordinate.latitude, "lon" : coordinate.longitude]
    do {
      let json = try NSJSONSerialization.dataWithJSONObject(arr, options: [])
      self.socket.emit("broadcast", json)
    } catch {
      print("error serializing JSON: \(error)")
    }
    
  }
  
  func write(offer : PassengerOffer) {
    let json_dict = ["from_type" : "passenger", "price" : offer.price, "destination" : ["lat" : offer.destination.latitude, "lon" : offer.destination.longitude], "current" : ["lat" : offer.currentPosition.latitude, "lon" : offer.currentPosition.longitude]]
    do {
      let json = try NSJSONSerialization.dataWithJSONObject(json_dict, options: [])
      print(NSString(data: json, encoding: NSUTF8StringEncoding))
      self.socket.emit("broadcast", json)
    } catch {
      print("error serializing JSON: \(error)")
    }
  }
  
}
