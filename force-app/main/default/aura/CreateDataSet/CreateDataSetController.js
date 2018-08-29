({
    onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null)
            helper.connectCometd(component);
    },
    change : function(component, event, helper) {  
        var source = event.getSource().get('v.name');
        console.log(source);
    },
    init : function(component, event, helper) {  
        helper.init(component, event, helper);
    },
    search : function(component, event, helper) {
        helper.search(component, event, helper);		
    },
    select : function(component, event, helper) {
        helper.select(component, event, helper);		
    },
    loadmore : function(component, event, helper) {
        helper.loadmore(component, event, helper);		
    },
    refresh : function(component, event, helper) {
        helper.refresh(component, event, helper);		
    },
    create : function(component, event, helper) {
        helper.create(component, event, helper);		
    },
    getLabels : function(component, event, helper) {
        helper.getLabels(component, event, helper);		
    },
    keyCheck : function(component, event, helper) {
        if (event.which == 13){
            helper.search(component, event, helper);
        }
    }    
})