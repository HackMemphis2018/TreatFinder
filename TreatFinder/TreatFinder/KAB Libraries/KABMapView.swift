//
//  KABMapView.swift
//  TripTracker
//
//  Created by Keaton Burleson on 7/16/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import MapKit

class KABMapView: MKMapView {
    var kabDelegate: KABMapViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

    public func dropPin(coordinate: CLLocationCoordinate2D, title: String, house: HouseModel) {
        let annotation = KABAnnotation()
        let centerCoordinate = coordinate
        annotation.coordinate = centerCoordinate
        annotation.title = title
        annotation.house = house
        self.addAnnotation(annotation)
    }

    public func zoomToRoute(polyline: MKPolyline) {
        self.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
    }
}

extension KABMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if(view.annotation is KABAnnotation){
            let kAnnotation = (view.annotation as! KABAnnotation)
            let house = kAnnotation.house
            kabDelegate?.didSelectHouse(data: house!)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let line = MKPolylineRenderer(overlay: overlay)
            line.strokeColor = .red
            line.lineWidth = 5
            return line
        } else if (overlay is MKPointAnnotation) {
            let point = MKPointAnnotation()
            point.title = overlay.title!
            point.subtitle = overlay.subtitle!
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is KABAnnotation) {
            return mapView.view(for: annotation)
        }
        
        let reuseId = "truckAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = false
        }
        else {
            annotationView?.annotation = annotation
        }
        
        
        return annotationView
    }
}

protocol KABMapViewDelegate{
    func didSelectHouse(data: HouseModel)
}
