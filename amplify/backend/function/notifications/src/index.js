var AWS = require('aws-sdk');
var pinpoint = new AWS.Pinpoint({region: process.env.region});

exports.handler = async (event) => {
    console.log('begin notification', event);
    
    var channelType = 'GCM';
    
    if (event.messageType === 'APNSMessage') {
        channelType = 'APNS_SANDBOX';
    }
    
    const sendMessagesParams = {
        ApplicationId: process.env.PINPOINT_APP_ID,
        MessageRequest: {
            Addresses: {
                [event.deviceToken]: {
                    ChannelType: channelType
                }
            },
            MessageConfiguration: {
                [event.messageType]: {
                    Action: 'OPEN_APP',
                    Title: 'Message received',
                    SilentPush: false,
                    Body: event.message
                }
            }
        }
    };

    return await new Promise( (resolve, reject) => {
        pinpoint.sendMessages(sendMessagesParams, (sendMessagesErr, sendMessagesData) => {
            if (sendMessagesErr) reject(sendMessagesErr);
            else resolve(sendMessagesData);
        });
    });

   
};
