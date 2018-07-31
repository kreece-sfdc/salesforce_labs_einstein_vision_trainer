public with sharing class VisionHelper 
{
	public static void CreateDataset(List<Id> dataSetIds)
    {
        EinsteinVision_PredictionService predictionService = new EinsteinVision_PredictionService();
        List<Dataset__c> dataSetsToUpdate = new List<Dataset__c>();
        List<Dataset_Label__c> dataSetLabelsToUpdate = new List<Dataset_Label__c>();
        
        List<Dataset__c> dataSets = [SELECT Name, Dataset_Id__c FROM Dataset__c WHERE Id IN: dataSetIds];
        
        List<Dataset_Label__c> dataSetLabels = [SELECT Name, Dataset_Label_Id__c, Dataset__c FROM Dataset_Label__c WHERE Dataset__c IN: dataSetIds];
        
        Map<EinsteinVision_Dataset, Map<Dataset__c, List<Dataset_Label__c>>> results = new Map<EinsteinVision_Dataset, Map<Dataset__c, List<Dataset_Label__c>>>();
        
        for(Dataset__c dataSet : dataSets)
        {
            List<Dataset_Label__c> dataSetLabelList = new List<Dataset_Label__c>();  
            List<string> labels = new List<string>();
            EinsteinVision_Dataset dataSetResult = null;
            
            for(Dataset_Label__c dataSetLabel : dataSetLabels)
            {
                if(dataSetLabel.Dataset__c == dataSet.Id)
                {
                    dataSetLabelList.add(dataSetLabel);
                    labels.add(dataSetLabel.Name);
                }
                
                if(dataSet.Dataset_Id__c == null)
                {
					dataSetResult = predictionService.createDataset(dataSet.Name, labels);
                }
                else
                {
                    dataSetResult.id = (long)dataSet.Dataset_Id__c;
                }
            }
            
            Map<Dataset__c, List<Dataset_Label__c>> dataSetMap = new Map<Dataset__c, List<Dataset_Label__c>>();
            dataSetMap.put(dataSet, dataSetLabelList);
            results.put(dataSetResult, dataSetMap);
		}
        
        for(EinsteinVision_Dataset dataSetResult : results.keySet())
        {
            Map<Dataset__c, List<Dataset_Label__c>> dataSetMap = results.get(dataSetResult);
            
            for(Dataset__c dataSet : dataSetMap.keySet())
            {
                List<Dataset_Label__c> dataSetLabelList = dataSetMap.get(dataSet);
                
                for(Dataset_Label__c dataSetLabel : dataSetLabelList)
                {
                    if(dataSetResult.LabelSummary != null && dataSetResult.LabelSummary.Labels != null)
                    {
                        for(EinsteinVision_Label label : dataSetResult.LabelSummary.Labels)
                        {
                            if(dataSetLabel.Name == label.name)
                            {
                                dataSetLabel.Dataset_Label_Id__c = label.id;
                                dataSetLabelsToUpdate.add(dataSetLabel);
                            }
                        }
                    }
                }
                
                if(dataSet.Dataset_Id__c == null)
                {
                    dataSet.Dataset_Id__c = dataSetResult.id;
                    dataSetsToUpdate.add(dataSet);
                }
            }
        }
        
        
        if(!dataSetsToUpdate.isEmpty())
        {
            upsert dataSetsToUpdate;
        }
        
        if(!dataSetLabelsToUpdate.isEmpty())
        {
            upsert dataSetLabelsToUpdate;
        }
    }
    
    public static void CreateExamples(Id dataSetLabelId)
    {
        EinsteinVision_PredictionService predictionService = new EinsteinVision_PredictionService();
        
        List<Dataset_Image__c> dataSetImagesToUpdate = new List<Dataset_Image__c>();
        
        List<Dataset_Label__c> dataSetLabels = [SELECT Name, Dataset_Label_Id__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Label__c WHERE Id =: dataSetLabelId];
		Dataset_Label__c dataSetLabel = dataSetLabels.get(0);
        
        List<Dataset_Image__c> dataSetImages = [SELECT Name, Dataset_Image_Id__c, Raw_Image__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Image__c WHERE Dataset__c =: dataSetLabel.Dataset__c AND Dataset_Image_Id__c = NULL];
        
        Map<EinsteinVision_Example, Dataset_Image__c> dataSetImageMap = new Map<EinsteinVision_Example, Dataset_Image__c>();
        
        for(Dataset_Image__c image : dataSetImages)
        {
            HttpResponse res = HttpHelper.Request('GET', image.Raw_Image__c, null, null);
            Blob imageBlob;
            
            if(res != null)
            {
                imageBlob = res.getBodyAsBlob();
            }
            
            EinsteinVision_Example example = predictionService.createExample((long)dataSetLabel.Dataset__r.Dataset_Id__c, image.Name, (long)dataSetLabel.Dataset_Label_Id__c, imageBlob);
            
            if(example != null && example.id != null)
            {
                system.debug(example.id);
	            dataSetImageMap.put(example, image);
            }
        }
        
        for(EinsteinVision_Example example : dataSetImageMap.keySet())
        {
            Dataset_Image__c image = dataSetImageMap.get(example);
            
            image.Dataset_Image_Id__c = example.id;
            dataSetImagesToUpdate.add(image);
        }
        
        if(!dataSetImagesToUpdate.isEmpty())
        {
            upsert dataSetImagesToUpdate;
        }
    }
}