//
//  GotenbergHealth.swift
//  gotenberg-kit
//
//  Created by Florian Friedrich on 10.06.25.
//

import struct Foundation.Date

/// Contains heatlh information of a Gotenberg instance.
public struct GotenbergHealth: Sendable, Equatable, Codable {
    /// Describes possible health status values.
    public enum Status: String, Sendable, Hashable, Codable {
        /// The system status is unknown
        case unknown
        /// The system is up and running
        case up
        /// The system is down
        case down
    }

    /// Represents the status of a Gotenberg module.
    public struct ModuleStatus: Sendable, Equatable, Codable {
        /// The current status of the module.
        public let status: Status
        /// The timestamp of the last check of the module.
        public let timestamp: Date
    }

    /// Contains the health details for each module of a Gotenberg instance.
    public struct ModuleDetails: Sendable, Equatable, Codable {
        private enum CodingKeys: String, CodingKey {
            case chromium
            case libreOffice = "libreoffice"
        }

        /// The status of the Chromium module.
        public let chromium: ModuleStatus?
        /// The status of the LibreOffice module.
        public let libreOffice: ModuleStatus?
    }

    /// The overall system status.
    public let status: Status
    /// The module details of the system.
    public let details: ModuleDetails?
}
