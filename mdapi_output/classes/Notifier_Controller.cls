public with sharing class Notifier_Controller 
{
	@AuraEnabled
    public static String getSessionId() 
    {
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    public static Map<string, object> CheckDatasetTraining(Id dataSetId)
    {
        Dataset__c dataSet = [SELECT Id, Name, Dataset_Id__c, Model_Id__c FROM Dataset__c WHERE Id =: dataSetId LIMIT 1];
        
        if(dataSet != null)
        {
        	EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        	Map<string, object> modelResult = service.getModel(dataSet.Model_Id__c);

            if(modelResult != null)
            {
                if(modelResult.containsKey('status'))
                {
                	string status = (string)modelResult.get('status');
                    
                    if(status == 'SUCCEEDED') 
                    {
                    	EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Succeeded);
                    }
                    else if(status == 'FAILED') 
                    {
                    	EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Failed);
                    }
                    else
                    {
                        if(modelResult.containsKey('progress'))
                        {
                            decimal progress = (decimal)modelResult.get('progress');
                            EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Started, string.valueOf(progress));
                        }
                    }
                }
                
                return modelResult;
            }
        }
        
        return null;
    }
}