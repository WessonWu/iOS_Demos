import Foundation

let MemoryCapacity: Int = 4 * 1024 * 1024
let DiskCapacity: Int = 20 * 1024 * 1024
let DiskPath: String = "ThorCache"

open class URLCacheManager {
    private let storage: URLCache
    
    public static let shared: URLCacheManager = {
       return URLCacheManager(memoryCapacity: MemoryCapacity,
                              diskCapacity: DiskCapacity,
                              diskPath: DiskPath)
    }()

    public init(memoryCapacity: Int, diskCapacity: Int, diskPath: String) {
        storage = URLCache(memoryCapacity: memoryCapacity,
                           diskCapacity: diskCapacity,
                           diskPath: diskPath)
    }
    
    
    open var memoryCapacity: Int {
        get { return storage.memoryCapacity }
        set { storage.memoryCapacity = newValue }
    }
    
    open var diskCapacity: Int {
        get { return storage.diskCapacity }
        set { storage.diskCapacity = newValue }
    }
    
    open var currentMemoryUsage: Int { return storage.currentMemoryUsage }
    open var currentDiskUsage: Int { return storage.currentMemoryUsage }
    
    open func storeCachedResponse(cachedResponse: CachedURLResponse, for request: URLRequest) {
        storage.storeCachedResponse(cachedResponse, for: request)
    }
    
    open func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        let response = storage.cachedResponse(for: request)
        response?.response.isFromCache = true
        return response
    }
    
    open func removeCachedResponse(for request: URLRequest) {
        storage.removeCachedResponse(for: request)
    }
    
    open func removeCachedResponses(since date: Date) {
        storage.removeCachedResponses(since: date)
    }
    
    open func removeAllCachedResponses() {
        storage.removeAllCachedResponses()
    }
}

extension URLResponse {
    private static var isFromCacheKey = "URLResponse_IsFromCacheKey"
    internal fileprivate(set) var isFromCache: Bool {
        get {
            if let number = objc_getAssociatedObject(self, &URLResponse.isFromCacheKey) as? NSNumber {
                return number.boolValue
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &URLResponse.isFromCacheKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
