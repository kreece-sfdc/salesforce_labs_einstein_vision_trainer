public with sharing class DatasetImageBatch implements Database.Batchable<Dataset_Image__c>, Database.Stateful, Database.AllowsCallouts
{
    public List<Id> DataSetIds { get; set; }
    public Map<Id, long> DataSetImageLabelMap { get; set; }
    public Map<Id, long> DataSetMap { get; set; }
    
    
    public Iterable<Dataset_Image__c> start(Database.BatchableContext bc)
    {
        return [SELECT Name, Dataset_Image_Id__c, Raw_Image__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Image__c WHERE Dataset__c IN: DataSetIds AND Dataset_Image_Id__c = NULL];
    }
    
    public void execute(Database.BatchableContext bc, List<Dataset_Image__c> scope)
    {
        EinsteinVision_PredictionService predictionService = new EinsteinVision_PredictionService();
        List<Dataset_Image__c> dataSetImagesToUpdate = new List<Dataset_Image__c>();
        
        for(Dataset_Image__c dataSetImage : scope)
        {
            HttpResponse res = HttpHelper.Request('GET', dataSetImage.Raw_Image__c, null, null);
            Blob imageBlob;
            
            if(res != null)
            {
                imageBlob = res.getBodyAsBlob();
            }
            
            //Id dataSetLabelId = DataSetImageLabelMap.get(dataSetImage.Id);
            
            long dataSetLabelVisionId = DataSetImageLabelMap.get(dataSetImage.Id);
            long dataSetId = DataSetMap.get(dataSetImage.Dataset__c);
            
            system.debug('Writing Image: ' + dataSetImage.Name + ' with Label: ' + dataSetLabelVisionId);
            EinsteinVision_Example example = predictionService.createExample(dataSetId, dataSetImage.Name, dataSetLabelVisionId, imageBlob);
            
            if(example != null)
            {
                DataSetMap.put(dataSetImage.Id, example.id);
            }
            
        }
        
        for(Dataset_Image__c dataSetImage : scope)
        {
            if(dataSetImage.Dataset_Image_Id__c == null && DataSetMap.containsKey(dataSetImage.Id))
            {
                dataSetImage.Dataset_Image_Id__c = DataSetMap.get(dataSetImage.Id);
                dataSetImagesToUpdate.add(dataSetImage);
            }
        }
        
        if(!dataSetImagesToUpdate.isEmpty())
        {
            upsert dataSetImagesToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
        for(Id dataSetId : DataSetIds)
        {
            EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Accepted);
        }
    }
}