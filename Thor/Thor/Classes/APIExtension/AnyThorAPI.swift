import Foundation
// MARK: - Deprecated
@available(*, deprecated)
public typealias SimpleThorAPIWrapper = AnyThorTarget

@available(*, deprecated)
public extension SimpleThorAPIWrapper {
    init<API: ThorAPI>(api: API) {
        self.init(api)
    }
}
