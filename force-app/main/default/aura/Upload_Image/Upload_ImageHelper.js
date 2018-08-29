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
        
        helper.createRecord(component, event, helper);
    },
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var action = component.get("c.PushToCustomObject");
        action.setParams({ fileName : fileName , documentId : documentId, model: component.get('v.model') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.classificationId', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    createRecord : function(component, event, helper) {
        var recordId = component.get("v.myRecordId");
        var action = component.get("c.CreateRecordId");
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.myRecordId",response.getReturnValue());
                helper.getModels(component, event, helper);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    getModels : function(component, event, helper) {
        var recordId = component.get("v.myRecordId");
        var action = component.get("c.GetModels");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.models", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
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
                var newSubscription = cometd.subscribe('/event/Classification_Event__e',
                                                       function(platformEvent) {
                                                           console.log('Platform event received: '+ JSON.stringify(platformEvent));
                                                           helper.onReceiveNotification(component, event, helper, platformEvent);
                                                       }
                                                      );
                // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
                console.log('connected...');
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
            classificationId : platformEvent.data.payload.Classification_Id__c
        };
        
        
        if(newNotification.action == 'Classification_Results')
        {
            helper.getResults(component, event, helper, newNotification.classificationId);
        }
    },
    getResults : function(component, event, helper, classificationId) {
        var action = component.get("c.GetResults");
        action.setParams({ classificationId : component.get('v.classificationId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.results", response.getReturnValue());
                console.log(component.get("v.results"));
                var spinner = component.find("spinner");
	            $A.util.toggleClass(spinner, "slds-hide");
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})