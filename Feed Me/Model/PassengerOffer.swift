//
//  PassengerOffer.swift
//  Feed Me
//
//  Created by Insaf Latypov on 16.12.15.
//  Copyright © 2015 Ron Kliffer. All rights reserved.
//

import Foundation
import CoreLocation

class PassengerOffer {
  let currentPosition : CLLocationCoordinate2D
  let destination : CLLocationCoordinate2D
  let price : Double
  
  init(currentPosition : CLLocationCoordinate2D, destination : CLLocationCoordinate2D, price : Double) {
    self.currentPosition = currentPosition
    self.destination = destination
    self.price = price
  }
}