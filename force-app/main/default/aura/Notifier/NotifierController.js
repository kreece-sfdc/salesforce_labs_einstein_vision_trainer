({
    init : function(component, event, helper) {  
        helper.init(component, event, helper);
    },
	onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null)
            helper.connectCometd(component);
    }
})