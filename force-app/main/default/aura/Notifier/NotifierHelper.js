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
                var newSubscription = cometd.subscribe('/event/flowcontest__Dataset_Event__e',
                                                       function(platformEvent) {
                                                           console.log('Platform event received: '+ JSON.stringify(platformEvent));
                                                           helper.onReceiveNotification(component, event, helper, platformEvent);
                                                       }
                                                      );
                
                var classification = cometd.subscribe('/event/flowcontest__Classification_Event__e',
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
        
        var utilitybar = component.find('utilitybar');
        
        var helper = this;
        // Extract notification from platform event
        var newNotification = {
            time : $A.localizationService.formatDateTime(
                platformEvent.data.payload.CreatedDate, 'HH:mm'),
            action : platformEvent.data.payload.flowcontest__Action__c,
            message : platformEvent.data.payload.flowcontest__Message__c,
            dataSetId : platformEvent.data.payload.flowcontest__Dataset_Id__c,
            classificationId : platformEvent.data.payload.flowcontest__Classification_Id__c 
        };
        
        if(newNotification.action == 'Dataset_Training_Queued' ||
          newNotification.action == 'Dataset_Training_Started')
        {
            var inProgress = component.get('v.inProgress');
            
            if(inProgress == false) {
                component.set('v.inProgress', true);
        		helper.checkTraining(component, event, helper, newNotification.dataSetId);   
            }
        }
        
        // helper.refresh(component,event,helper);
        if(newNotification.action == 'Dataset_Accepted')
        {
            helper.displayToast(component, 'success', 'Dataset successfully accepted by Einstein Vision');
        }
        else if(newNotification.action == 'Dataset_Training_Queued')
        {
            utilitybar.setUtilityLabel({ label: 'Queued' });
            utilitybar.setUtilityIcon({
                icon: 'pause'
            }); 
        }
        else if(newNotification.action == 'Dataset_Training_Started')
        {
            component.set('v.progress', newNotification.message * 100);
            utilitybar.setUtilityLabel({ label: 'Training... (' + newNotification.message * 100 + '%)' });
            
            utilitybar.setUtilityIcon({
                icon: 'spinner'
            });
        }
        else if(newNotification.action == 'Dataset_Training_Succeeded')
        {
            // utility bar progress
            //utilitybar.minimizeUtility(); 
            utilitybar.setUtilityLabel({ label: 'Einstein Vision Trainer' });
            utilitybar.setUtilityIcon({
                icon: 'check'
            });
            component.set('v.inProgress', false);
            component.set('v.progress', 0);
        }
        else if(newNotification.action == 'Dataset_Training_Failed')
        {
            utilitybar.setUtilityLabel({ label: 'Einstein Vision Trainer' });
            utilitybar.setUtilityIcon({
                icon: 'close'
            });
            component.set('v.inProgress', false);
            component.set('v.progress', 0);
        }
        else if(newNotification.action == 'Classification_Results')
        {
            helper.displayToast(component, 'success', 'Image Classification Results received by Einstein Vision');
        }
        else if(newNotification.action == 'Classification_Created')
        {
            helper.displayToast(component, 'success', 'Image Classification sent to Einstein Vision');
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
    checkTraining : function(component, event, helper, dataSetId) {
        
        var id = setInterval(
            function() { 
                
                var action = component.get("c.CheckDatasetTraining");
                action.setParams({ dataSetId : dataSetId });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        var dataSetResult = response.getReturnValue();
                        if(dataSetResult != null) {
                            if(dataSetResult.status == 'FAILED') {
                                helper.displayToast(component, 'error', dataSetResult.failureMsg);
                                clearInterval(id);
                            }
                            else if(dataSetResult.status == 'SUCCEEDED') {
                                helper.displayToast(component, 'success', 'The ' + dataSetResult.name + ' dataset has trained successfully');
                                clearInterval(id);
                            }
                            else {
                                console.log(dataSetResult.status);        
                            }
                        }
                    }
                });
                
                $A.enqueueAction(action);
                
            }, 5000
        );
    }
})