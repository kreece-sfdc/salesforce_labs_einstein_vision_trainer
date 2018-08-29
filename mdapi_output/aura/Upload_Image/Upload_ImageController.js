({
    handleUploadFinished : function(component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
        
    },
    init : function(component, event, helper) {
        helper.init(component, event, helper);
    },
    getModels : function(component, event, helper) {
        helper.getModels(component, event, helper);
    },
    onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null)
            helper.connectCometd(component);
    }
})