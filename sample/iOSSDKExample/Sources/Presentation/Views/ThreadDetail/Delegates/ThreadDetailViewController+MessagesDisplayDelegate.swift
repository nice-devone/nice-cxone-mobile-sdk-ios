import Kingfisher
import MapKit
import MessageKit
import UIKit

extension ThreadDetailViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ChatAppearance.customerFontColor : ChatAppearance.agentFontColor
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            let color: UIColor = isFromCurrentSender(message: message) ? ChatAppearance.agentCellColor : ChatAppearance.customerCellColor
            
            return [.foregroundColor: color]
        case .url:
            let color: UIColor = isFromCurrentSender(message: message) ? ChatAppearance.agentCellColor : ChatAppearance.customerCellColor
            
            return [
                .foregroundColor: color,
                .underlineColor: color,
                .underlineStyle: NSNumber(value: NSUnderlineStyle.double.rawValue)
            ]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ChatAppearance.customerCellColor : ChatAppearance.agentCellColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            
            if !presenter.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !presenter.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            
            if !presenter.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !presenter.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let formatter = PersonNameComponentsFormatter()
        let initials = message.sender.senderId == "000000"
            ? "??"
            : formatter.personNameComponents(from: message.sender.displayName).map { components in
                formatter.style = .abbreviated
            
                return formatter.string(from: components)
            } ?? "??"
        
        avatarView.set(avatar: Avatar(image: nil, initials: initials))
        avatarView.isHidden = presenter.isNextMessageSameSender(at: indexPath)
        avatarView.backgroundColor = ChatAppearance.agentCellColor
        avatarView.tintColor = ChatAppearance.agentFontColor
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = ChatAppearance.backgroundColor.cgColor
    }
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                Log.error(CommonError.unableToParse("url", from: media))
                return
            }
            
            if ["jpg", "png", "heic"].contains(imageURL.pathExtension) {
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: imageURL, placeholder: media.placeholderImage)
            } else {
                imageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: imageURL, seconds: 1), placeholder: media.placeholderImage)
            }
        default:
            Log.warning(.failed("Unsupported media message type."))
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        
        return annotationView
    }
    
    func animationBlockForLocation(
        message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> ((UIImageView) -> Void)? {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0) {
                view.layer.transform = CATransform3DIdentity
            }
        }
    }
    
    func snapshotOptionsForLocation(
        message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> LocationMessageSnapshotOptions {
        LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ChatAppearance.customerFontColor : ChatAppearance.agentFontColor
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioPlayer.configureAudioCell(cell, message: message)
    }
}
