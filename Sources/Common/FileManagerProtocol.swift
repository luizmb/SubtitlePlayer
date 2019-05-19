import Foundation

public protocol FileManagerProtocol {
    func contents(atPath path: String) -> Data?
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
#if !os(Linux)
    func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL?
#endif
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL]
    func fileExists(atPath path: String) -> Bool
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func linkItem(at srcURL: URL, to dstURL: URL) throws
    func removeItem(at URL: URL) throws
    func removeItem(atPath path: String) throws
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
}

public enum FileManagerError: Error {
    case couldNotRetrieveContentsOfFolder(parentFolder: URL, error: Error)
    case fileNotFound(fileName: String, parent: URL, childrenFoundOnParent: [URL])
    case specialFolderNotFound(FileManager.SearchPathDirectory)
    case groupFolderNotFound(groupName: String)
    case folderNotFound(folderName: String)
    case fileCopyHasFailed(sourceFile: URL, destinationFile: URL, error: Error)
    case fileDeletionHasFailed(path: String, error: Error)
    case createFolderHasFailed(folder: String, error: Error)
    case fileAlreadyExists(path: String)
    case fileCreationHasFailed(path: String)
}

extension FileManagerProtocol {
    public func specialFolder(_ folder: FileManager.SearchPathDirectory) -> Result<URL, FileManagerError> {
        return urls(for: folder, in: .userDomainMask)
            .first
            .toResult(orError: FileManagerError.specialFolderNotFound(folder))
    }

#if !os(Linux)
    public func groupFolder(group: String) -> Result<URL, FileManagerError> {
        return containerURL(forSecurityApplicationGroupIdentifier: group)
            .toResult(orError: FileManagerError.groupFolderNotFound(groupName: group))
    }
#endif

    public func contents(of parentFolder: URL) -> Result<[URL], FileManagerError> {
        return Result(catching: { try contentsOfDirectory(at: parentFolder, includingPropertiesForKeys: nil, options: []) })
            .biMap(success: identity, failure: { error in FileManagerError.couldNotRetrieveContentsOfFolder(parentFolder: parentFolder, error: error) })
    }

    public func folder(named folderName: String, in parentFolder: URL) -> Result<URL, FileManagerError> {
        let folderUrl = parentFolder.appendingPathComponent(folderName, isDirectory: true)

        var isDirectory: ObjCBool = true
        if fileExists(atPath: folderUrl.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return .success(folderUrl)
        } else {
            return .failure(.folderNotFound(folderName: folderName))
        }
    }

    public func file(named fileName: String, in parentFolder: URL) -> Result<URL, FileManagerError> {
        let fileUrl = parentFolder.appendingPathComponent(fileName, isDirectory: false)

        if fileExists(atPath: fileUrl.path) {
            return .success(fileUrl)
        } else {
            return .failure(.fileNotFound(fileName: fileName, parent: parentFolder, childrenFoundOnParent: contents(of: parentFolder).value ?? []))
        }
    }

    public func copy(file source: URL, to destination: URL) -> Result<Void, FileManagerError> {
        return Result(catching: {
            try copyItem(at: source, to: destination)
        }).biMap(success: identity, failure: {
            FileManagerError.fileCopyHasFailed(sourceFile: source, destinationFile: destination, error: $0)
        })
    }

    public func delete(file: URL) -> Result<Void, FileManagerError> {
        return Result(catching: {
            try removeItem(at: file)
        }).biMap(success: identity, failure: {
            FileManagerError.fileDeletionHasFailed(path: file.absoluteString, error: $0)
        })
    }

    public func delete(file: String) -> Result<Void, FileManagerError> {
        return Result(catching: {
            try removeItem(atPath: file)
        }).biMap(success: identity, failure: {
            FileManagerError.fileDeletionHasFailed(path: file, error: $0)
        })
    }

    public func ensureFolderExists(_ folder: String, createIfNeeded: Bool = false) -> Result<String, FileManagerError> {
        var isDirectory: ObjCBool = true
        if fileExists(atPath: folder, isDirectory: &isDirectory), isDirectory.boolValue {
            return .success(folder)
        }

        if !createIfNeeded {
            return .failure(FileManagerError.folderNotFound(folderName: folder))
        }

        return Result(catching: {
            try createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
            return folder
        }).biMap(success: identity, failure: {
            FileManagerError.createFolderHasFailed(folder: folder, error: $0)
        })
    }

    public func save(_ data: Data, into path: String) -> Result<String, FileManagerError> {
        if fileExists(atPath: path) {
            return .failure(FileManagerError.fileAlreadyExists(path: path))
        } else if createFile(atPath: path, contents: data, attributes: nil) {
            return .success(path)
        } else {
            return .failure(FileManagerError.fileCreationHasFailed(path: path))
        }
    }
}

extension FileManager: FileManagerProtocol { }
