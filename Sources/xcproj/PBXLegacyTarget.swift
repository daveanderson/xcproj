import Foundation

/// This is the element for a build target for external build tool configuration.

public class PBXLegacyTarget: PBXObject, Hashable {
    
    /// Target build arguments string.
    public var buildArgumentsString: String? /// Possibly that this isn't optional

    /// Target build configuration list.
    public var buildConfigurationList: String?
    
    /// Target build phases.
    public var buildPhases: [String]
    
    /// Target build tool path.
    public var buildToolPath: String? /// Possibly that this isn't optional

    /// Target build working directory.
    public var buildWorkingDirectory: String? /// Possibly that this isn't optional
    
    /// Target dependencies.
    public var dependencies: [String]
    
    /// Target name.
    public var name: String
    
    /// Target product name.
    public var productName: String?
    
    // passBuildSettingsInEnvironment
    public var passBuildSettingsInEnvironment: UInt = 0 /// Not sure what the default is
        
    public init(reference: String,
                name: String,
                buildArgumentsString: String? = nil,
                buildConfigurationList: String? = nil,
                buildPhases: [String] = [],
                buildToolPath: String? = nil,
                buildWorkingDirectory: String? = nil,
                dependencies: [String] = [],
                productName: String? = nil,
                passBuildSettingsInEnvironment: UInt = 0) {
        self.buildArgumentsString = buildArgumentsString
        self.buildConfigurationList = buildConfigurationList
        self.buildPhases = buildPhases
        self.buildToolPath = buildToolPath
        self.buildWorkingDirectory = buildWorkingDirectory
        self.dependencies = dependencies
        self.name = name
        self.productName = productName
        self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironment
        super.init(reference: reference)
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case buildArgumentsString
        case buildConfigurationList
        case buildPhases
        case buildToolPath
        case buildWorkingDirectory
        case dependencies
        case name
        case productName
        case passBuildSettingsInEnvironment
        case reference
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(.name)
        self.buildArgumentsString = try container.decodeIfPresent(.buildArgumentsString)
        self.buildConfigurationList = try container.decodeIfPresent(.buildConfigurationList)
        self.buildPhases = try container.decodeIfPresent(.buildPhases) ?? []
        self.buildToolPath = try container.decodeIfPresent(.buildToolPath)
        self.buildWorkingDirectory = try container.decodeIfPresent(.buildWorkingDirectory)
        self.dependencies = try container.decodeIfPresent(.dependencies) ?? []
        self.productName = try container.decodeIfPresent(.productName)
        let passBuildSettingsInEnvironmentString: String? = try container.decodeIfPresent(.passBuildSettingsInEnvironment)
        self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironmentString.flatMap(UInt.init) ?? 0
        try super.init(from: decoder)
    }
    
    public static func == (lhs: PBXLegacyTarget,
                           rhs: PBXLegacyTarget) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.buildArgumentsString == rhs.buildArgumentsString &&
            lhs.buildConfigurationList == rhs.buildConfigurationList &&
            lhs.buildPhases == rhs.buildPhases &&
            lhs.buildToolPath == rhs.buildToolPath &&
            lhs.buildWorkingDirectory == rhs.buildWorkingDirectory &&
            lhs.dependencies == rhs.dependencies &&
            lhs.name == rhs.name &&
            lhs.productName == rhs.productName &&
            lhs.passBuildSettingsInEnvironment == rhs.passBuildSettingsInEnvironment
    }
    
    func plistValues(proj: PBXProj, isa: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(isa))
        let buildConfigurationListComment = "Build configuration list for \(isa) \"\(name)\""
        if let buildArgumentsString = buildArgumentsString { // might not be optional
            dictionary["buildArgumentsString"] = .string(CommentedString(buildArgumentsString))
        }
        if let buildConfigurationList = buildConfigurationList {
            dictionary["buildConfigurationList"] = .string(CommentedString(buildConfigurationList, comment: buildConfigurationListComment))
        }
        dictionary["buildPhases"] = .array(buildPhases
            .map { buildPhase in
                let comment = proj.buildPhaseName(buildPhaseReference: buildPhase)
                return .string(CommentedString(buildPhase, comment: comment))
        })
        if let buildToolPath = buildToolPath {
            dictionary["buildToolPath"] = .string(CommentedString(buildToolPath))
        }
        if let buildWorkingDirectory = buildWorkingDirectory {
            dictionary["buildWorkingDirectory"] = .string(CommentedString(buildWorkingDirectory))
        }
        dictionary["dependencies"] = .array(dependencies.map {.string(CommentedString($0, comment: PBXTargetDependency.isa))})
        dictionary["name"] = .string(CommentedString(name))
        if let productName = productName {
            dictionary["productName"] = .string(CommentedString(productName))
        }
        dictionary["passBuildSettingsInEnvironment"] = .string(CommentedString("\(passBuildSettingsInEnvironment)"))
        return (key: CommentedString(self.reference, comment: name),
                value: .dictionary(dictionary))
    }
    
}


// // MARK: - PBXNativeTarget Extension (PlistSerializable)
//
// extension PBXNativeTarget: PlistSerializable {
//
//     func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
//         return plistValues(proj: proj, isa: PBXNativeTarget.isa)
//     }
//
// }
