
import Foundation
@testable import CXOneChatSDK

class CXOneChatMock: CXOneChat {
    var uuidForVisitor: UUID = UUID()
    var newCustomer: Customer = Customer(id: "ASDF", firstName: "Test", lastName: "User")
    override var customer: Customer? {
      get {
        return newCustomer
      }
      set {
          self.newCustomer = newValue ?? Customer(id: "ASDF", firstName: "Test", lastName: "User")
      }
    }
    
    override var visitorId: UUID? {
        get {
            return uuidForVisitor
        }
        set {
            uuidForVisitor = newValue ?? UUID()
        }
    }
    override var connected: Bool {
        isConected
    }
    var isConected: Bool = true
}
