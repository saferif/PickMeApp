//
//  MapViewController.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import PPRevealSideViewController

class MapViewController: UIViewController, SocketClientProtocol {
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  
  let locationManager = CLLocationManager()
  //let client = SocketClient(host: "46.101.122.129", port: 80)
  var updateOnce = true
  var markers_dictionary = [String: GMSMarker]()
  var userInfo: NSData!
  var client: SocketClient!
  
  var toNeedBroadcast : Bool = false;
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var pickMeButton : UIButton!
  @IBOutlet weak var destinationTextField : UITextField!
  @IBOutlet weak var costTextField : UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    client = SocketClient.instance()
    client.passengerCallback = self
    client.connect()
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
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2DMake(37.4, -122)
    marker.title = "Hello World"
    marker.map = mapView
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  func didSocketDisconnected(data: String) {
    markers_dictionary[data]?.map = nil
    markers_dictionary[data] = nil
  }
  
  
  func didFinishReading(data: String) {
    print("Data to UI: ", data)
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
      if (json["from_type"] as! String == "driver") {
        let uuid = json["from"] as! String
        let latitude = json["lat"] as! Double
        let longitude = json["lon"] as! Double
        if let m = markers_dictionary[uuid] {
          m.position = CLLocationCoordinate2DMake(latitude, longitude)
        } else {
          let marker = GMSMarker()
          marker.title = uuid
          marker.position = CLLocationCoordinate2DMake(latitude, longitude)
          marker.map = mapView
          markers_dictionary[uuid] = marker
        }
      }
    } catch {
      print("error serializing JSON: \(error)")
    }
  }
  
  @IBAction func pickMeTapped(sender : AnyObject) {
    if (toNeedBroadcast) {
      pickMeButton.setTitle("Pick me", forState: .Normal)
      toNeedBroadcast = false
    } else {
      pickMeButton.setTitle("Cancel the request", forState: .Normal)
      toNeedBroadcast = true
    }
  }
}

// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension MapViewController : CLLocationManagerDelegate, GMSMapViewDelegate {
  
  func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
    if let infoView = NSBundle.mainBundle().loadNibNamed("UserInfoView", owner: nil, options: nil).first as? UserInfoView {
      return infoView
    } else {
      return nil
    }
  }

  func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    let geocoder = GMSGeocoder()
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      if let address = response?.firstResult() {
        let lines = address.lines as! [String]
        self.destinationTextField.text = lines.joinWithSeparator("\n")
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
  }
  
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
      /*  marker.position = CLLocationCoordinate2DMake(37.4, location.coordinate.longitude)
        marker.title = "Hello World"
        marker.map = mapView*/
        updateOnce = false

      }
      //print(client.connected)
     // marker.position = CLLocationCoordinate2DMake(marker.position.latitude + 0.0001, marker.position.longitude)
      
      print(location.coordinate)
      
      if (toNeedBroadcast) {
        let offer : PassengerOffer
        if let price = Double(costTextField.text!) {
          offer = PassengerOffer(destination: location.coordinate, price: price)
        } else {
          offer = PassengerOffer(destination: location.coordinate, price: 0.0)
        }
        client.write(offer)
      }
      
     // locationManager.stopUpdatingLocation()
    }
    
  }
}