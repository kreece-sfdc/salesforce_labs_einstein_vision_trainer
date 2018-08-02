({
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File "+fileName+" Uploaded successfully."
        });
        toastEvent.fire();
        var action = component.get("c.PushToCustomObject");
        action.setParams({ fileName : fileName , documentId : documentId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                response.getReturnValue();
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
    }
        /* Open the file

        $A.get('e.lightning:openFiles').fire({
            recordIds: [documentId]
        });
        
        */
})