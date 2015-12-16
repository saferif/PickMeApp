//
//  DriverViewController.swift
//  Feed Me
//
//  Created by Insaf Latypov on 16.12.15.
//  Copyright © 2015 Ron Kliffer. All rights reserved.
//

import UIKit

class DriverViewController: UIViewController {
  
  var updateOnce = true
  let locationManager = CLLocationManager()
  
  @IBOutlet weak var mapView: GMSMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad();
    
    locationManager.delegate = self
    let authState = CLLocationManager.authorizationStatus()
    if (authState == CLAuthorizationStatus.NotDetermined) {
      locationManager.requestWhenInUseAuthorization()
    } else if (authState != CLAuthorizationStatus.Denied) {
      locationManager.startUpdatingLocation()
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
    }
    
    mapView.delegate = self
  }
}

extension DriverViewController : GMSMapViewDelegate {
  
}

extension DriverViewController : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse {
      
      locationManager.startUpdatingLocation()
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
      
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      if (updateOnce) {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        updateOnce = false
      }
    }
  }
}
