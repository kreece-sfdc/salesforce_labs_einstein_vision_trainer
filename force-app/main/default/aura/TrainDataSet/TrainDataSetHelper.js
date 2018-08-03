({
	init : function(component, event, helper) {
    	var action = component.get("c.GetDatasets");
        action.setParams({ hasDataSetId : true });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dataSets = response.getReturnValue();
                component.set('v.dataSets', dataSets);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);  
    },
    train : function(component, event, helper) {
    	var action = component.get("c.TrainDataset");
        action.setParams({ dataSetIc : component.get('dataSetId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //var dataSets = response.getReturnValue();
                component.set('v.isComplete', true);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);  
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
                var newSubscription = cometd.subscribe('/event/Auth_Event__e',
                                                       function(platformEvent) {
                                                           console.log('Platform event received: '+ JSON.stringify(platformEvent));
                                                           helper.onReceiveNotification(component, event, helper, platformEvent);
                                                       }
                                                      );
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
            provider : platformEvent.data.payload.Provider__c
        };
        // helper.refresh(component,event,helper);
        if(newNotification.provider == 'Unsplash' && newNotification.action == 'Deploy_Success')
        {
            helper.displayToast(component, 'success', 'Authentication Complete!');
            helper.check_auth(component,event,helper);
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
    check_auth : function(component,event,helper) {
        var action = component.get("c.HasAccessToken");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                component.set('v.hasAuth', result);
                if(result == false) {
                    helper.auth(component, event, helper);
                }
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);	
    },
    auth : function(component, event, helper) {
        var action = component.get("c.GetAuthUrl");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.authUrl', result);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);	
    },
})