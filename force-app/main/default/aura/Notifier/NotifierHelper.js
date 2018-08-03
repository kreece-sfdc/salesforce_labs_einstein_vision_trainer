({
    init : function(component, event, helper) {
        component.set('v.cometdSubscriptions', []);
        
        // Disconnect CometD when leaving page
        window.addEventListener('unload', function(event) {
            helper.disconnectCometd(component);
        });
        
        
        // Retrieve session id
        var action_s = component.get('c.getSessionId');
        action_s.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                component.set('v.sessionId', response.getReturnValue());
                if (component.get('v.cometd') != null)
                    helper.connectCometd(component, event, helper);
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action_s);
    },
    connectCometd : function(component,event, helper) {
        var helper = this;
        // Configure CometD
        var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
        var cometd = component.get('v.cometd');
        cometd.configure({
            url: cometdUrl,
            requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
            appendMessageTypeToURL : false
        });
        cometd.websocketEnabled = false;
        // Establish CometD connection
        console.log('Connecting to CometD: '+ cometdUrl);
        cometd.handshake(function(handshakeReply) {
            if (handshakeReply.successful) {
                console.log('Connected to CometD.');
                // Subscribe to platform event
                var newSubscription = cometd.subscribe('/event/Dataset_Event__e',
                                                       function(platformEvent) {
                                                           console.log('Platform event received: '+ JSON.stringify(platformEvent));
                                                           helper.onReceiveNotification(component, event, helper, platformEvent);
                                                       }
                                                      );
                
                var classification = cometd.subscribe('/event/Classification_Event__e',
                                                       function(platformEvent) {
                                                           console.log('Platform event received: '+ JSON.stringify(platformEvent));
                                                           helper.onReceiveNotification(component, event, helper, platformEvent);
                                                       }
                                                      );
                // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                subscriptions.push(classification);
                component.set('v.cometdSubscriptions', subscriptions);
                // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
            }
            else
                console.error('Failed to connected to CometD.');
        });
    },
    disconnectCometd : function(component) {
        var cometd = component.get('v.cometd');
        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            var subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function (subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);
        // Disconnect CometD
        cometd.disconnect();
        console.log('CometD disconnected.');
    },
    onReceiveNotification : function(component, event, helper, platformEvent) {
        
        var helper = this;
        // Extract notification from platform event
        var newNotification = {
            time : $A.localizationService.formatDateTime(
                platformEvent.data.payload.CreatedDate, 'HH:mm'),
            action : platformEvent.data.payload.Action__c,
            dataSetId : platformEvent.data.payload.Dataset_Id__c,
            classificationId : platformEvent.data.payload.Classification_Id__c 
        };
        
        // helper.refresh(component,event,helper);
        if(newNotification.action == 'Dataset_Accepted')
        {
            helper.displayToast(component, 'success', 'Dataset successfully accepted by Einstein Vision');
        }
        else if(newNotification.action == 'Classification_Results')
        {
            helper.displayToast(component, 'success', 'Image Classification Results have been received by Einstein Vision');
        }
    },
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
})