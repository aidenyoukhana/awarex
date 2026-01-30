import Foundation
import SwiftUI
import MapKit
import CoreLocation

@Observable
final class MapViewModel: NSObject, CLLocationManagerDelegate {
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var cameraPosition: MapCameraPosition = .automatic
    var userLocation: CLLocationCoordinate2D?
    var selectedMapIncident: Incident?
    var showUserLocation: Bool = true
    var mapStyle: MapStyleOption = .standard
    var isLocationAuthorized: Bool = false
    var locationError: String?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func centerOnUserLocation() {
        guard let location = userLocation else { return }
        cameraPosition = .region(MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }
    
    func centerOnIncident(_ incident: Incident) {
        cameraPosition = .region(MKCoordinateRegion(
            center: incident.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        selectedMapIncident = incident
    }
    
    func distanceToIncident(_ incident: Incident) -> String? {
        guard let userLoc = userLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let incidentCLLocation = CLLocation(latitude: incident.latitude, longitude: incident.longitude)
        
        let distance = userCLLocation.distance(from: incidentCLLocation)
        
        if distance < 1000 {
            return String(format: "%.0f m away", distance)
        } else {
            return String(format: "%.1f km away", distance / 1000)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        if cameraPosition == .automatic {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAuthorized = true
            startUpdatingLocation()
        case .denied, .restricted:
            isLocationAuthorized = false
            locationError = "Location access denied. Please enable in Settings."
        case .notDetermined:
            isLocationAuthorized = false
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Location error: \(error.localizedDescription)"
    }
}

enum MapStyleOption: String, CaseIterable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"
}
