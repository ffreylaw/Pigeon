//
//  ARViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import SceneKit
import MapKit

protocol ARViewControllerDelegate {
    func updateLocation() -> CLLocation?
    func handleCancel()
}

class ARViewController: UIViewController {
    
    var delegate: ARViewControllerDelegate?
    
    let sceneLocationView = SceneLocationView()
    
    var userAnnotation: MKPointAnnotation?
    
    var locationEstimateAnnotation: MKPointAnnotation? // cannot get best location estimate, use last one
    
    var updateLocationTimer: Timer?
    
    var targetLocation: CLLocation?
    
    var targetLocationNode: LocationAnnotationNode?
    
    var targetUserAnnotation: MKPointAnnotation?
    
    var updateInfoLabelTimer: Timer?
    
//    var adjustNorthByTappingSidesOfScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTargetAnnotation()
        setupNavigation()
        setupViews()
        setupTimers()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "AR"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(handleMap))
    }
    
    fileprivate func initTargetAnnotation() {
        if let targetLocation = targetLocation {
            // Add pin
            let coordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let location = CLLocation(coordinate: coordinate, altitude: targetLocation.altitude)
            let image = UIImage(named: "pin")!
            targetLocationNode = LocationAnnotationNode(location: location, image: image)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: targetLocationNode!)
        }
    }
    
    func setupTimers() {
        // Updating infoLabel
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(ARViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        updateLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(ARViewController.updateLocation),
            userInfo: nil,
            repeats: true)
    }
    
    func setupViews() {
        // Set to true to display an arrow which points north.
        //        sceneLocationView.orientToTrueNorth = false
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        
        //        sceneLocationView.showAxesNode = false
        //        sceneLocationView.showFeaturePoints = true
        
        view.addSubview(sceneLocationView)
        
        sceneLocationView.locationDelegate = self
        
        sceneLocationView.addSubview(infoLabel)
        
        view.addSubview(debugLabel)
        debugLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        debugLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: false) {
            self.delegate?.handleCancel()
        }
    }
    
    @objc fileprivate func handleMap() {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
    }
    
    @objc func updateLocation() {
        updateUserLocation()
        updateAnnotationLocation()
    }
    
    func updateUserLocation() {
        targetLocation = delegate?.updateLocation()
        
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
            }
        }
        
        if let targetLocation = targetLocation {
            DispatchQueue.main.async {
                if self.targetUserAnnotation == nil {
                    self.targetUserAnnotation = MKPointAnnotation()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.targetUserAnnotation?.coordinate = targetLocation.coordinate
                }, completion: nil)
            }
        }
    }
    
    func updateAnnotationLocation() {
        
    }
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//
//        if let touch = touches.first {
//            if touch.view != nil {
////                if (mapView == touch.view! ||
////                    mapView.recursiveSubviews().contains(touch.view!)) {
////                    centerMapOnUserLocation = false
////                } else {
//
//                    let location = touch.location(in: self.view)
//
//                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
//                        print("left side of the screen")
//                        sceneLocationView.moveSceneHeadingAntiClockwise()
//                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
//                        print("right side of the screen")
//                        sceneLocationView.moveSceneHeadingClockwise()
//                    } else {
//                        //                        let image = UIImage(named: "pin")!
//                        //                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
//                        //                        annotationNode.scaleRelativeToDistance = true
//                        //                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//                    }
////                }
//            }
//        }
//    }
    
    let debugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        return label
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.numberOfLines = 0
        return label
    }()
    
}
