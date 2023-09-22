import CXoneChatSDK
import MessageKit
import UIKit

extension Message: MessageType {

    public var sender: SenderType { senderInfo }
    
    /// The unique identifier for the message.
    public var messageId: String { id.uuidString }

    /// The date the message was sent.
    public var sentDate: Date { createdAt }

    /// The kind of message and its underlying kind.
    public var kind: MessageKind {
        let message = contentType.message
        
        if let attachment = attachments.first {
            return handle(message: message, with: attachment)
        }
        
        return handleRichMessage(message)
    }
}

// MARK: - Helpers

extension MessageContentType {

    var message: String {
        switch self {
        case .text(let entity):
            return entity.text.mapNonEmpty { $0 } ?? ""
        case .plugin(let entity):
            return entity.text?.mapNonEmpty { $0 } ?? ""
        case .richLink(let entity):
            return entity.title
        case .quickReplies(let entity):
            return entity.title
        case .listPicker(let entity):
            return entity.title
        case .unknown:
            return ""
        }
    }
}

private extension Message {
    
    func handle(message: String, with attachment: Attachment) -> MessageKind {
        switch attachment.mimeType {
        case _ where attachment.mimeType.contains("image"):
            return .photo(MessageMediaItem(from: attachment))
        case _ where attachment.mimeType.contains("video"):
            return .video(MessageMediaItem(from: attachment))
        case _ where attachment.mimeType.contains("audio"):
            do {
                return .audio(try MessageAudioItem(from: attachment))
            } catch {
                error.logError()
            }
        case _ where attachment.mimeType.contains("application/pdf") || attachment.mimeType.contains("text"):
            guard let item = MessageLinkItem(attachment: attachment) else {
                return .text(message)
            }
            
            return .linkPreview(item)
        default:
            break
        }
        
        return .photo(MessageMediaItem(from: attachment))
    }
    
    func handleRichMessage(_ message: String) -> MessageKind {
        switch contentType {
        case .plugin(let entity):
            return .custom(entity)
        case .richLink(let entity):
            return .custom(entity)
        case .quickReplies(let entity):
            return .custom(entity)
        case .listPicker(let entity):
            return .custom(entity)
        default:
            return .text(message)
        }
    }
}
