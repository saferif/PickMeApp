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

class MapViewController: UIViewController, SocketClientProtocol {
  
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  
  let locationManager = CLLocationManager()
  let client = SocketClient(host: "46.101.122.129", port: 80)
  var updateOnce = true
  var markers_dictionary = [String: GMSMarker]()
  
  @IBOutlet weak var mapView: GMSMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    client.callback = self
    client.connect()
    locationManager.delegate = self
    mapView.delegate = self
    locationManager.requestWhenInUseAuthorization()
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
    } catch {
      print("error serializing JSON: \(error)")
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
  
  func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
    
    //разобраться с хренью снизу
    
    
    //let myFirstButton = UIButton()
    //myFirstButton.setTitle("Test", forState: .Normal)
    //myFirstButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    //myFirstButton.frame = CGRectMake(15, -50, 300, 500)
    //myFirstButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
    
    //self.view.addSubview(myFirstButton)
    return true
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
      client.write(location.coordinate)
      
     // locationManager.stopUpdatingLocation()
    }
    
  }
}