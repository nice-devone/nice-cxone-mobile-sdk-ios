import InputBarAccessoryView
import UIKit

// MARK: - ChatAttachmentDelegate

/// ChatAttachmentDelegate is a protocol that can recieve notifications from the ChatAttachmentDelegate
protocol ChatAttachmentDelegate: AnyObject {
    
    /// Can be used to determine if the ChatAttachmentDelegate should be inserted into an InputStackView
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - shouldBecomeVisible: If the ChatAttachmentDelegate should be presented or dismissed
    func attachmentManager(_ manager: ChatAttachmentManager, shouldBecomeVisible: Bool)
    
    /// Notifys when an attachment has been inserted into the ChatAttachmentDelegate
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachment: The attachment that was inserted
    ///   - index: The index of the attachment in the ChatAttachmentDelegate's attachments array
    func attachmentManager(_ manager: ChatAttachmentManager, didInsert attachment: ChatAttachmentManager.Attachment, at index: Int)
    
    /// Notifys when an attachment has been removed from the ChatAttachmentDelegate
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachment: The attachment that was removed
    ///   - index: The index of the attachment in the ChatAttachmentDelegate's attachments array
    func attachmentManager(_ manager: ChatAttachmentManager, didRemove attachment: ChatAttachmentManager.Attachment, at index: Int)
    
    /// Notifys when the ChatAttachmentDelegate was reloaded
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachments: The ChatAttachmentDelegate's attachments array
    func attachmentManager(_ manager: ChatAttachmentManager, didReloadTo attachments: [ChatAttachmentManager.Attachment])
    
    /// Notifys when the AddAttachmentCell was selected
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachments: The index of the AddAttachmentCell
    func attachmentManager(_ manager: ChatAttachmentManager, didSelectAddAttachmentAt index: Int)
}

extension ChatAttachmentDelegate {
    
    func attachmentManager(_ manager: ChatAttachmentManager, didInsert attachment: ChatAttachmentManager.Attachment, at index: Int) { }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didRemove attachment: ChatAttachmentManager.Attachment, at index: Int) { }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didReloadTo attachments: [ChatAttachmentManager.Attachment]) { }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didSelectAddAttachmentAt index: Int) { }
}

// MARK: - ChatAttachmentDataSource

/// ChatAttachmentDelegateDataSource is a protocol to passes data to the ChatAttachmentDelegate
protocol ChatAttachmentDataSource: AnyObject {
    
    /// The AttachmentCell for the attachment that is to be inserted into the AttachmentView
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachment: The object
    ///   - index: The index in the AttachmentView
    /// - Returns: An AttachmentCell
    func attachmentManager(_ manager: ChatAttachmentManager, cellFor attachment: ChatAttachmentManager.Attachment, at index: Int) -> ChatAttachmentCell
    
    /// The CGSize of the AttachmentCell for the attachment that is to be inserted into the AttachmentView
    ///
    /// - Parameters:
    ///   - manager: The ChatAttachmentDelegate
    ///   - attachment: The object
    ///   - index: The index in the AttachmentView
    /// - Returns: The size of the given attachment
    func attachmentManager(_ manager: ChatAttachmentManager, sizeFor attachment: ChatAttachmentManager.Attachment, at index: Int) -> CGSize?
}

extension ChatAttachmentDataSource {
    
    // Default implementation, if data source method is not given, use autocalculated default.
    func attachmentManager(_ manager: ChatAttachmentManager, sizeFor attachment: ChatAttachmentManager.Attachment, at index: Int) -> CGSize? {
        nil
    }
}

// MARK: - ChatAttachmentManager

class ChatAttachmentManager: NSObject, InputPlugin {

    enum Attachment {
        case image(UIImage)
        case url(URL)
        case data(Data)
    }
    
    // MARK: - Properties
    
    /// A protocol that can recieve notifications from the `ChatAttachmentDelegate`
    weak var delegate: ChatAttachmentDelegate?
    
    /// A protocol to passes data to the `ChatAttachmentDelegate`
    weak var dataSource: ChatAttachmentDataSource?
    
    lazy var attachmentView: AttachmentCollectionView = { [weak self] in
        let attachmentView = AttachmentCollectionView()
        attachmentView.dataSource = self
        attachmentView.delegate = self
        attachmentView.register(cell: ChatImageAttachmentCell.self)
        attachmentView.register(cell: ChatAttachmentCell.self)
        attachmentView.register(cell: ChatDataAttachmentCell.self)
        
        return attachmentView
    }()
    
    /// The attachments that the managers holds
    private(set) var attachments = [Attachment]() {
        didSet {
            reloadData()
        }
    }
    
    /// A flag you can use to determine if you want the manager to be always visible
    var isPersistent = false {
        didSet {
            attachmentView.reloadData()
        }
    }
    
    /// A flag to determine if the AddAttachmentCell is visible
    var showAddAttachmentCell = true {
        didSet {
            attachmentView.reloadData()
        }
    }
    
    // MARK: - InputManager
    
    func reloadData() {
        attachmentView.reloadData()
        delegate?.attachmentManager(self, didReloadTo: attachments)
        delegate?.attachmentManager(self, shouldBecomeVisible: !attachments.isEmpty || isPersistent)
    }
    
    /// Invalidates the `ChatAttachmentDelegate` session by removing all attachments
    func invalidate() {
        attachments = []
    }
    
    /// Appends the object to the attachments
    ///
    /// - Parameter object: The object to append
    func handleInput(of object: AnyObject) -> Bool {
        let attachment: Attachment
        
        switch object {
        case let image as UIImage where object is UIImage:
            attachment = .image(image)
        case let url as URL where object is URL:
            attachment = .url(url)
        case let data as Data where object is Data:
            attachment = .data(data)
        default:
            return false
        }
        
        insertAttachment(attachment, at: attachments.count)
        
        return true
    }
    
    // MARK: - API
    
    /// Performs an animated insertion of an attachment at an index
    ///
    /// - Parameter index: The index to insert the attachment at
    func insertAttachment(_ attachment: Attachment, at index: Int) {
        attachmentView.performBatchUpdates({
            self.attachments.insert(attachment, at: index)
            self.attachmentView.insertItems(at: [IndexPath(row: index, section: 0)])
        }, completion: { _ in
            self.attachmentView.reloadData()
            self.delegate?.attachmentManager(self, didInsert: attachment, at: index)
            self.delegate?.attachmentManager(self, shouldBecomeVisible: !self.attachments.isEmpty || self.isPersistent)
        })
    }
    
    /// Performs an animated removal of an attachment at an index
    ///
    /// - Parameter index: The index to remove the attachment at
    func removeAttachment(at index: Int) {
        let attachment = attachments[index]
        
        attachmentView.performBatchUpdates({
            self.attachments.remove(at: index)
            self.attachmentView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }, completion: { _ in
            self.attachmentView.reloadData()
            self.delegate?.attachmentManager(self, didRemove: attachment, at: index)
            self.delegate?.attachmentManager(self, shouldBecomeVisible: !self.attachments.isEmpty || self.isPersistent)
        })
    }
}

// MARK: - UICollectionViewDataSource

extension ChatAttachmentManager: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row == attachments.count else {
            Log.warning("Did tap unknown item.")
            return
        }
        
        delegate?.attachmentManager(self, didSelectAddAttachmentAt: indexPath.row)
        delegate?.attachmentManager(self, shouldBecomeVisible: attachments.isEmpty || self.isPersistent)
    }
    
    func numberOfItems(inSection section: Int) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        attachments.count + (showAddAttachmentCell ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == attachments.count && showAddAttachmentCell {
            return addAttachmentCell(in: collectionView, at: indexPath)
        }
        
        let attachment = attachments[indexPath.row]
        
        if let cell = dataSource?.attachmentManager(self, cellFor: attachment, at: indexPath.row) {
            return cell
        } else {
            let cell: ChatAttachmentCell
            
            switch attachment {
            case .image(let image):
                cell = collectionView.dequeue(for: indexPath) as ChatImageAttachmentCell
                (cell as? ChatImageAttachmentCell)?.imageView.image = image
            case .data, .url:
                cell = collectionView.dequeue(for: indexPath) as ChatDataAttachmentCell
            }
            
            cell.attachment = attachment
            cell.indexPath = indexPath
            cell.manager = self
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
 
extension ChatAttachmentManager: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = attachmentView.intrinsicContentHeight
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            height -= (layout.sectionInset.bottom + layout.sectionInset.top + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
        
        return CGSize(width: height, height: height)
    }
    
    private func addAttachmentCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> ChatAttachmentCell {
        let cell = collectionView.dequeue(for: indexPath) as ChatAttachmentCell
        cell.deleteButton.isHidden = true
        
        // Draw a plus
        let frame = CGRect(
            origin: CGPoint(x: cell.bounds.origin.x, y: cell.bounds.origin.y),
            size: CGSize(width: cell.bounds.width - cell.padding.left - cell.padding.right, height: cell.bounds.height - cell.padding.top - cell.padding.bottom)
        )
        let strokeWidth: CGFloat = 3
        let length: CGFloat = frame.width / 2
        let vLayer = CAShapeLayer()
        
        vLayer.path = UIBezierPath(
            roundedRect: CGRect(x: frame.midX - (strokeWidth / 2), y: frame.midY - (length / 2), width: strokeWidth, height: length),
            cornerRadius: 5
        ).cgPath
        vLayer.fillColor = UIColor.lightGray.cgColor
        
        let hLayer = CAShapeLayer()
        hLayer.path = UIBezierPath(
            roundedRect: CGRect(x: frame.midX - (length / 2), y: frame.midY - (strokeWidth / 2), width: length, height: strokeWidth),
            cornerRadius: 5
        ).cgPath
        hLayer.fillColor = UIColor.lightGray.cgColor
        
        cell.containerView.layer.addSublayer(vLayer)
        cell.containerView.layer.addSublayer(hLayer)
        
        return cell
    }
}
