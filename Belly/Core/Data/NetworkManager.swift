//
//  NetworkManager.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import Foundation
import Network
import Combine

/// Network connectivity manager for checking internet availability
final class NetworkManager: ObservableObject {
    
    // MARK: - Shared Instance
    static let shared = NetworkManager()
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var connectionType: ConnectionType = .none
    
    // MARK: - Private Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // MARK: - Connection Types
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case other
        case none
        
        var displayName: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .ethernet: return "Ethernet"
            case .other: return "Other"
            case .none: return "No Connection"
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else if path.status == .satisfied {
            connectionType = .other
        } else {
            connectionType = .none
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if network is available for API calls
    func isNetworkAvailable() -> Bool {
        return isConnected
    }
    
    /// Check if the connection is reliable for AI operations
    func isReliableConnection() -> Bool {
        return isConnected && (connectionType == .wifi || connectionType == .ethernet)
    }
    
    /// Get current connection status as string
    var connectionStatus: String {
        return isConnected ? "Connected via \(connectionType.displayName)" : "No Internet Connection"
    }
}
