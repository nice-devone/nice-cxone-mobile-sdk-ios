import Swinject

extension ObjectScope {

    /// An instance provided by the `Container` is shared within the `Container` and its child `Containers`.
    static let resetableContainer = ObjectScope(
        storageFactory: PermanentStorage.init,
        description: "resetableContainer"
    )
}
