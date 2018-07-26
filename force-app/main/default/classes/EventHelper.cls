public with sharing class EventHelper 
{
	public static void PublishAuthEvent(string provider, string action)
    {
        Auth_Event__e authData = new Auth_Event__e
            (
                Provider__c = provider,
                Action__c = action
            );
        
        EventBus.publish(authData);
    }
    
    public static void PublishDatasetEvent(string dataSetId, string action)
    {
        Dataset_Event__e dataSetData = new Dataset_Event__e
            (
                Dataset_Id__c = dataSetId,
                Action__c = action
            );
        
        EventBus.publish(dataSetData);
    }
    
    public static void HandleAuthTrigger(List<Auth_Event__e> items)
    {
        for(Auth_Event__e item : items)
        {
        }
    }
}