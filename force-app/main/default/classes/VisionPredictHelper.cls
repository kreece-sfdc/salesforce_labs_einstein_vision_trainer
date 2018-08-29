public with sharing class VisionPredictHelper 
{
	@InvocableMethod(label='Submit Image for Classification to Einstein Vision')
    public static void SubmitImage(List<Id> itemIds)
    {
        EinsteinVision_PredictionService ps = new EinsteinVision_PredictionService();
        
        Map<Image_Classification__c, EinsteinVision_PredictionResult> classificationResults = new Map<Image_Classification__c, EinsteinVision_PredictionResult>();
        
        List<Image_Classification__c> items = [SELECT Url__c, Status__c, Classifier__c FROM Image_Classification__c WHERE Id IN: itemIds];
        
        for(Image_Classification__c item : items)
        {
            EinsteinVision_PredictionResult results = ps.predictUrl(item.Classifier__c, item.Url__c, null);
             
            classificationResults.put(item, results);
        }
        
        List<Image_Classification_Result__c> results = new List<Image_Classification_Result__c>();
        
        for(Image_Classification__c item : classificationResults.keySet())
        {
            for(EinsteinVision_Probability result : classificationResults.get(item).probabilities)
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
            EventHelper.PublishClassificationEvent(item.Id, Constants.Classification_Results);
        }
        
        if(!results.isEmpty())
        {
            upsert items;
            insert results;
		}
    }
}