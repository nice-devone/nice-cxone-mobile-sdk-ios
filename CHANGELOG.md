<a name="1.0.0"></a>
## 1.0.0 - 2023-01-18

### Features

- Logging PoC
- Error handling (forwarded to the host app)

- Connection
    - Ping to ensure connection state (call the socket)
    - Execute trigger manually
    - Handle unexpected disconnect

- Customer
    - Save customer credentials (these are not custom fields)
    - Customer authorisation
    - Customer reconnect
    - OAuth

- Customer Custom Fields
    - Save customer custom fields (global user custom data)

- Threads
    - Update thread name
    - „Read“ flag
    - „Delivered“ flag
    - Threads load
    - Contact inbox assignee change (assign to someone else)
    - Recover thread
    - Typing indicator
    - Archive thread
    - Load thread metadada (info about thread)
    - Handle proactive action
        - Welcome message
        - Custom popup box


- Contact Custom Fields
    - Save contact custom fields (single case custom data - ex. Name, email..)

- Messages
    - Send/Receive attachments (open, play, save, share)
        - Image
        - Video
        - Documents
    - Handle (specific) message
        - Text message
        - Plugin
            - Gallery
            - Menu
            - Text and Buttons
            - Quick Replies
            - Satisfaction Survey
            - Custom
            - Sub Elements 
                - Text
                - Title
                - File
                - Button/iFrame Button
    - Previous message load

- Analytics
    - page view
    - chat window open
    - app visit
    - Conversion - need to make deep dive
    - custom visitor event
    - proactive action display
    - proactive action success/failure
    - typing start/end
