//
//  File.swift
//  
//
//  Created by kjoe on 3/9/22.
//

import Foundation
var eventID = ""
var consumerId = UUID()
let threadIdOnExternal = "43C193A3-0F80-4DEE-A19C-80FA0E5D0E35"
let messageIdOnExternalPlatform = UUID()

let loadThreadMetadataString = """
    {
        "eventId": "\(eventID)",
        "action": "chatWindowEvent",
        "payload": {
            "consumerIdentity": {
                "idOnExternalPlatform": "\(consumerId.uuidString)"
            },
            "data": {
                "thread": {
                    "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_43C193A3-0F80-4DEE-A19C-80FA0E5D0E35",
                    "idOnExternalPlatform": "43C193A3-0F80-4DEE-A19C-80FA0E5D0E35"
                }
            },
            "brand": {
                "id": 1386
            },
            "channel": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
            },
            "eventType": "LoadThreadMetadata"
        }
    }
"""

let sendMessageString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "firstName": "Yoel",
            "idOnExternalPlatform": "\(consumerId.uuidString)",
            "lastName": "Jimenez del valle"
        },
        "data": {
            "thread": {
                "idOnExternalPlatform": "43C193A3-0F80-4DEE-A19C-80FA0E5D0E35",
                "threadName": ""
            },
            "idOnExternalPlatform": "\(messageIdOnExternalPlatform.uuidString)",
            "browserFingerprint": {
                "location": "",
                "os": "",
                "country": "",
                "osVersion": "",
                "browserVersion": "",
                "browser": "",
                "language": "",
                "ip": ""
            },
            "attachments": [],
            "messageContent": {
                "type": "TEXT",
                "payload": {
                    "text": "new text",
                    "elements": []
                }
            },
            "consumer": {
                "customFields": []
            },
            "consumerContact": {
                "customFields": []
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "SendMessage"
    }
}
"""

let archiveThreadString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "thread": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)",
                "idOnExternalPlatform": "\(threadIdOnExternal)"
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "ArchiveThread"
    }
}
"""

let loadMoreMessageString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "scrollToken": "aaaaa",
            "thread": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)",
                "idOnExternalPlatform": "\(threadIdOnExternal)"
            },
            "consumerContact": {
                "id": "111222"
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "LoadMoreMessages"
    }
}
"""

let setCustomerContactFieldString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "consumerContact": {
                "id": "111222"
            },
            "thread": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)",
                "idOnExternalPlatform": "\(threadIdOnExternal)"
            },            
            "customFields": [
                {
                    "ident": "myFieldIdent",
                    "value": "This is new value"
                }
            ]
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "SetConsumerContactCustomFields"
    }
}
"""

let setCustomFieldString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "customFields": [
                {
                    "ident": "myFieldIdent",
                    "value": "This is new value"
                }
            ]
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "SetConsumerCustomFields"
    }
}
"""

let typingStartedString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "thread": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)"
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "SenderTypingStarted"
    }
}
"""

let typingEndedString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "thread": {
                "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)"
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "SenderTypingEnded"
    }
}
"""

let authorizePayloadString = """
{
    "eventId": "\(eventID)",
    "action": "register",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "authorization": {
                "authorizationCode": ""
            }
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "AuthorizeConsumer"
    }
}
"""

let messageSeenByCustomerString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "data": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4_\(threadIdOnExternal)",
            "idOnExternalPlatform": "\(threadIdOnExternal)"

        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "MessageSeenByConsumer"
    }
}
"""

let loadThreadsString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "FetchThreadList"
    }
}
"""

let recoverLivechatString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "RecoverLivechat"
    }
}
"""

let recoverThreadString = """
{
    "eventId": "\(eventID)",
    "action": "chatWindowEvent",
    "payload": {
        "consumerIdentity": {
            "idOnExternalPlatform": "\(consumerId.uuidString)"
        },
        "brand": {
            "id": 1386
        },
        "channel": {
            "id": "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4"
        },
        "eventType": "RecoverThread"
    }
}
"""

