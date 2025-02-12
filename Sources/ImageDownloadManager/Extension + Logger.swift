//
//  Extension + Logger.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 11.02.2025.
//

import OSLog

/// Typealias for easier access to the OSLog class, allowing for cleaner usage throughout the code.
typealias Log = OSLog

/// Helper class used solely to find the correct bundle for logging purposes.
/// This is necessary because `Bundle(for:)` requires a class reference.
private class BundleFinder {}

/// Extension of OSLog to provide custom logging configurations and helper methods for different log levels.
extension OSLog {

    /// The subsystem identifier for the log messages.
    /// By default, it's set to the bundle identifier of the current app or framework.
    static var subsystem: String = Bundle(for: BundleFinder.self).bundleIdentifier ?? ""

    /// Custom log category for image download operations.
    static let imageDownload = OSLog(subsystem: subsystem, category: "ImageDownload")

    // MARK: - Convenient Log Methods

    /// Logs an informational message.
    ///
    /// - Parameters:
    ///   - message: The message to be logged.
    ///   - log: The OSLog instance to use. Default is `.default`.
    static func info(_ message: String, log: OSLog = .default) {
        os_log(.info, log: imageDownload, "[INFO] \(message)")
    }

    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - message: The error message to be logged.
    ///   - log: The OSLog instance to use. Default is `.default`.
    static func error(_ message: String, log: OSLog = .default) {
        os_log(.error, log: imageDownload, "[ERROR] \(message)")
    }

    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - message: The debug message to be logged.
    ///   - log: The OSLog instance to use. Default is `.default`.
    static func debug(_ message: String, log: OSLog = .default) {
        os_log(.debug, log: imageDownload, "[DEBUG] \(message)")
    }

    /// Logs a fault message, typically used for severe issues that should never occur in production.
    ///
    /// - Parameters:
    ///   - message: The fault message to be logged.
    ///   - log: The OSLog instance to use. Default is `.default`.
    static func fault(_ message: String, log: OSLog = .default) {
        os_log(.fault, log: imageDownload, "[FAULT] \(message)")
    }
}
