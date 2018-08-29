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
        
        var dataSetId = component.get('v.dataSetId');
        var action = component.get("c.TrainDataset");
        action.setParams({ dataSetId : dataSetId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dataSetResult = response.getReturnValue();
                
                if(dataSetResult.status != 'SUCCEEDED') {
                    /*var spinner = component.find("spinner");
			        $A.util.toggleClass(spinner, "slds-hide");*/
                    //helper.checkTraining(component, event, helper, dataSetId);
                    
                    if(dataSetResult.status == 'QUEUED' || dataSetResult.status == 'RUNNING') {
                        helper.pushToast(component, event, helper, 'success', 'Dataset Training Started Successfully');
                        component.set('v.isComplete', true);
                    }
                    else if(dataSetResult.status == 'FAILED' || dataSetResult.status == 'SUCCEEDED') {
                        component.set('v.isComplete', true);
                    }
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
    pushToast : function(component, event, helper, type, displayMessage) {
        
        //var action = component.get("c.PushToast");
        
        //action.setParams({ dataSetId : dataSetId, action: actionMessage });
        
        //action.setCallback(this, function(response) {
            //var state = response.getState();
            //if (state === "SUCCESS") {
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    type: type,
                    message: displayMessage
                });
                toastEvent.fire();
                
            //}
            
        //});
        
        //$A.enqueueAction(action);  
    }
})