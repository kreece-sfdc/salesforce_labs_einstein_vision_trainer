public with sharing class VisionPredictHelper 
{
	@InvocableMethod(label='Submit Image for Classification to Einstein Vision')
    public static void SubmitImage(List<Id> itemIds)
    {
        Map<Image_Classification__c, List<Vision.Prediction>> classificationResults = new Map<Image_Classification__c, List<Vision.Prediction>>();
        string access_token = AuthHelper.GetVisionAccessToken();
        
        List<Image_Classification__c> items = [SELECT Url__c, Status__c FROM Image_Classification__c WHERE Id IN: itemIds];
        
        for(Image_Classification__c item : items)
        {
        	List<Vision.Prediction> results = Vision.predictUrl(item.Url__c, access_token, 'GeneralImageClassifier');
            
            classificationResults.put(item, results);
        }
        
        List<Image_Classification_Result__c> results = new List<Image_Classification_Result__c>();
        
        for(Image_Classification__c item : classificationResults.keySet())
        {
            for(Vision.Prediction result : classificationResults.get(item))
            {
                Image_Classification_Result__c res = new Image_Classification_Result__c
                    (
                        Image_Classification__c = item.Id,
                        Label__c = result.label,
                        Result__c = result.probability
                    );
                
                results.add(res);
            }
            
            item.Status__c = 'Completed';
        }
        
        if(!results.isEmpty())
        {
            upsert items;
            insert results;
		}
    }
}