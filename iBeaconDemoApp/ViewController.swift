//
//  ViewController.swift
//  iBeaconDemoApp
//
//  Created by 田栗信昭 on 2015/10/29.
//  Copyright © 2015年 田栗信昭. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var rssi: UILabel!
    
    let proximityUUID = NSUUID(UUIDString: "12345678-1234-1234-1234-123456789012")
    var region = CLBeaconRegion()
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Beacon領域(CLBeaconRegion)を生成
        region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: "EstimoteRegion")
        
        // デリゲートの設定
        self.manager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            // iBeaconによる領域観測を開始する。
            print("観測開始")
            self.status.text = "Starting Monirot"
            self.manager.startRangingBeaconsInRegion(self.region)
        case .NotDetermined:
            print("許可承認")
            self.status.text = "Starting Monitor"
            if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){
                self.status.text = "Starting Monitor For iOS ~>8.0"
                self.manager.requestAlwaysAuthorization()
            }else{
                self.status.text = "Starting Monitor For iOS <~8.0"
                self.manager.startRangingBeaconsInRegion(self.region)
            }
        case .Restricted, .Denied:
            print("Restricted")
            self.status.text = "Restricted Monitor"
        }
    }
    
    // 以下CCLocationManagerデリゲートの実装------------------------->
    // 観測開始に成功すると呼ばれる
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion){
        manager.requestStateForRegion(region)
        self.status.text = "Scanning..."
        print("scanning")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion){
        if(state == .Inside){
            manager.startRangingBeaconsInRegion(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region:CLRegion?, withError error: NSError){
        print("monitoringDidFailForRegion\(error)")
        self.status.text = "Error :("
    }
    
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        print("didFailWithError \(error)")
    }
    
    // 領域内に入った場合に呼ばれる
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion){
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        self.status.text = "Possible Match"
    }
    
    // 領域外に出た場合に呼ばれる
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion){
        manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        reset()
    }
    
    // 
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion){
        print(beacons)
        
        if(beacons.count == 0){ return }
        let beacon = beacons[0] 
        
        if(beacon.proximity == CLProximity.Unknown){
            self.distance.text = "Unknown Proximity"
            reset()
            return
        }else if(beacon.proximity == CLProximity.Immediate){
            self.distance.text = "Immediate"
        }else if(beacon.proximity == CLProximity.Near){
            self.distance.text = "Near"
        }else if(beacon.proximity == CLProximity.Far){
            self.distance.text = "Far"
        }
        self.status.text = "OK"
        self.uuid.text = beacon.proximityUUID.UUIDString
        self.major.text = "\(beacon.major)"
        self.minor.text = "\(beacon.minor)"
        self.accuracy.text = "\(beacon.accuracy)"
        self.rssi.text = "\(beacon.rssi)"
    }
    
    func reset(){
        self.status.text = "none"
        self.uuid.text = "none"
        self.major.text = "none"
        self.minor.text = "none"
        self.accuracy.text = "none"
        self.rssi.text = "none"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

