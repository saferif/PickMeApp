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
  let client = SocketClient.instance()
  var markers_dictionary = [String: GMSMarker]()
  var currentMarker : GMSMarker!
  var getUserData = [String: AnyObject]()
  
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var declineButton: UIButton!
  @IBOutlet weak var mapView: GMSMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad();
    acceptButton.hidden = true
    declineButton.hidden = true
    getUserData["available"] = false
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
    client.driverCallback = self
  }
  
  @IBAction func acceptRide(sender: UIButton) {
    client.approve(getUserData["uuid"] as! String)
    sleep(2)
    let alert = UIAlertController(title: "Passenger accepted", message: "You accepted a passenger!", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Finish ride", style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)

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
      client.write(location.coordinate)
    }
  }
  
  func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
    if ((getUserData["available"] as! Bool) == false) {
      let uuid = ((markers_dictionary as NSDictionary).allKeysForObject(marker) as! [String]).first
      currentMarker = marker
      markers_dictionary[uuid!] = currentMarker
      //dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
      self.client.getUserInfo(uuid!)
      return nil
    }
    
    if let infoView = NSBundle.mainBundle().loadNibNamed("UserInfoView", owner: nil, options: nil).first as? UserInfoView {
      infoView.username.text = getUserData["username"] as? String
      infoView.cost.text = String(getUserData["price"]!)
      infoView.userImage.image = UIImage(named:"walking")!
      acceptButton.hidden = false
      declineButton.hidden = false
      getUserData["available"] = false;
      return infoView
    } else {
      return nil
    }
    
  }

  
}

extension DriverViewController : SocketClientProtocol {
  
  func receivedApproval(data: String) {
  }
  
  func didFinishReading(data: String) {
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
      if (json["from_type"] as! String == "psngr") {
        let uuid = json["from"] as! String
     //   getUserData["uuid"] = json["uuid"]
         getUserData["uuid"] = uuid
        getUserData["price"] = json["price"]
        let latitude = json["current"]!!["lat"] as! Double
        let longitude = json["current"]!!["lon"] as! Double
        if let m = markers_dictionary[uuid] {
          m.position = CLLocationCoordinate2DMake(latitude, longitude)
        } else {
          let marker = GMSMarker()
         // marker.title = uuid
          marker.position = CLLocationCoordinate2DMake(latitude, longitude)
          marker.map = mapView
          markers_dictionary[uuid] = marker
        }
      }
    } catch {
      print("error serializing JSON: \(error)")
    }
  }
  
  func didFinishReadingUserData(data: String) {
    print("Data to UI: ", data)
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
      getUserData["uuid"] = json["uuid"]
      getUserData["username"] = json["username"]
      getUserData["carNumber"] = json["carNumber"]
      if (currentMarker == markers_dictionary[json["uuid"] as! String]) {
        getUserData["available"] = true;
        mapView.selectedMarker = currentMarker
        
      }
    } catch {
      print("error serializing JSON: \(error)")
    }
  }

  
  func didSocketDisconnected(data: String) {
    markers_dictionary[data]?.map = nil
    markers_dictionary[data] = nil
  }
}
