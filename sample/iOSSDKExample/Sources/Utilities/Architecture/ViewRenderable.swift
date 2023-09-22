import Foundation

public protocol ViewRenderable: AnyObject {
    associatedtype ViewState

    func render(state: ViewState)
}
