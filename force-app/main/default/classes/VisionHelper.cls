public with sharing class VisionHelper 
{
    @InvocableMethod(label='Create Dataset in Einstein Vision')
	public static void CreateDataset(List<Id> dataSetIds)
    {
        EinsteinVision_PredictionService predictionService = new EinsteinVision_PredictionService();
        
        List<Dataset__c> dataSetsToUpdate = new List<Dataset__c>();
        List<Dataset_Label__c> dataSetLabelsToUpdate = new List<Dataset_Label__c>();
        List<Dataset_Image__c> dataSetImagesToUpdate = new List<Dataset_Image__c>();
        
        List<Dataset__c> dataSets = [SELECT Name, Dataset_Id__c FROM Dataset__c WHERE Id IN: dataSetIds];
        List<Dataset_Label__c> dataSetLabels = [SELECT Name, Dataset_Label_Id__c, Dataset__c FROM Dataset_Label__c WHERE Dataset__c IN: dataSetIds];
        List<Dataset_Image__c> dataSetImages = [SELECT Name, Dataset_Image_Id__c, Raw_Image__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Image__c WHERE Dataset__c IN: dataSetIds AND Dataset_Image_Id__c = NULL];
        //Map<EinsteinVision_Dataset, Map<Dataset__c, List<Dataset_Label__c>>> results = new Map<EinsteinVision_Dataset, Map<Dataset__c, List<Dataset_Label__c>>>();
        
        Map<Id, long> dataSetMap = new Map<Id, long>();
        Map<Id, Id> dataSetLabelMap = new Map<Id, Id>();
        
        for(Dataset__c dataSet : dataSets)
        {
            List<Dataset_Label__c> dataSetLabelList = new List<Dataset_Label__c>();  
            List<string> labels = new List<string>();
            
            for(Dataset_Label__c dataSetLabel : dataSetLabels)
            {
                if(dataSetLabel.Dataset__c == dataSet.Id)
                {
                    dataSetLabelList.add(dataSetLabel);
                    labels.add(dataSetLabel.Name);
                }
            }
            
            if(dataSet.Dataset_Id__c == null)
            {
                EinsteinVision_Dataset dataSetResult = predictionService.createDataset(dataSet.Name, labels);
                
                if(dataSetResult != null)
                {
                    dataSetMap.put(dataSet.Id, dataSetResult.id);
                }
                
                if(dataSetResult != null && dataSetResult.labelSummary != null && dataSetResult.labelSummary.labels != null)
                {
                    for(EinsteinVision_Label label : dataSetResult.labelSummary.labels)
                    {
                        for(Dataset_Label__c dataSetLabel : dataSetLabelList)
                        {
                            if(dataSetLabel.Name == label.name)
                            {
                        		dataSetMap.put(dataSetLabel.Id, label.id);
                            }
                        }
                    }
                }
            }
            else
            {
                dataSetMap.put(dataSet.Id, (long)dataSet.Dataset_Id__c);
                
                for(Dataset_Label__c dataSetLabel : dataSetLabelList)
                {
                    dataSetMap.put(dataSetLabel.Id, (long)dataSetLabel.Dataset_Label_Id__c);
                }
                
                //dataSetResult.id = (long)dataSet.Dataset_Id__c;
            }
            
            dataSetLabelMap.put(dataSet.Id, dataSetLabelList.get(0).Id);
            
            /*Map<Dataset__c, List<Dataset_Label__c>> dataSetMap = new Map<Dataset__c, List<Dataset_Label__c>>();
            dataSetMap.put(dataSet, dataSetLabelList);
            results.put(dataSetResult, dataSetMap);*/
		}
        
        for(Dataset_Image__c dataSetImage : dataSetImages)
        {
            HttpResponse res = HttpHelper.Request('GET', dataSetImage.Raw_Image__c, null, null);
            Blob imageBlob;
            
            if(res != null)
            {
                imageBlob = res.getBodyAsBlob();
            }
            
            Id dataSetLabel = dataSetLabelMap.get(dataSetImage.Dataset__c);
            
            long dataSetLabelId = dataSetMap.get(dataSetLabel);
            long dataSetId = dataSetMap.get(dataSetImage.Dataset__c);
            
            EinsteinVision_Example example = predictionService.createExample(dataSetId, dataSetImage.Name, dataSetLabelId, imageBlob);
            
            if(example != null)
            {
                dataSetMap.put(dataSetImage.Id, example.id);
            }
        }
        
        for(Dataset__c dataSet : dataSets)
        {
            if(dataSet.Dataset_Id__c == null && dataSetMap.containsKey(dataSet.Id))
            {
                dataSet.Dataset_Id__c = dataSetMap.get(dataSet.Id);
                dataSetsToUpdate.add(dataSet);
            }
        }
        
        for(Dataset_Label__c dataSetLabel : dataSetLabels)
        {
            if(dataSetLabel.Dataset_Label_Id__c == null && dataSetMap.containsKey(dataSetLabel.Id))
            {
                dataSetLabel.Dataset_Label_Id__c = dataSetMap.get(dataSetLabel.Id);
                dataSetLabelsToUpdate.add(dataSetLabel);
            }
        }
        
        for(Dataset_Image__c dataSetImage : dataSetImages)
        {
            if(dataSetImage.Dataset_Image_Id__c == null && dataSetMap.containsKey(dataSetImage.Id))
            {
                dataSetImage.Dataset_Image_Id__c = dataSetMap.get(dataSetImage.Id);
                dataSetImagesToUpdate.add(dataSetImage);
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
        
        if(!dataSetImagesToUpdate.isEmpty())
        {
            upsert dataSetImagesToUpdate;
        }
        
        for(Dataset__c dataSet : dataSets)
        {
	        EventHelper.PublishDatasetEvent(dataSet.Id, Constants.Dataset_Accepted);
        }
        //CreateExamples(dataSetIds);
    }
    
    /*public static void CreateExamples(List<Id> dataSetIds)
    {
        EinsteinVision_PredictionService predictionService = new EinsteinVision_PredictionService();
        
        List<Dataset_Image__c> dataSetImagesToUpdate = new List<Dataset_Image__c>();
        
        List<Dataset_Label__c> dataSetLabels = [SELECT Name, Dataset_Label_Id__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Label__c WHERE Dataset__r.Id IN: dataSetIds];
		
        Map<Id, Dataset_Label__c> dataSetMap = new Map<Id, Dataset_Label__c>();
        
        for(Id dataSetId : dataSetIds)
        {
            for(Dataset_Label__c dataSetLabel : dataSetLabels)
            {
                if(dataSetLabel.Dataset__c == dataSetId && !dataSetMap.containsKey(dataSetId))
                {
                    dataSetMap.put(dataSetId, dataSetLabel);
                }
            }
        }
            
        List<Dataset_Image__c> dataSetImages = [SELECT Name, Dataset_Image_Id__c, Raw_Image__c, Dataset__c, Dataset__r.Dataset_Id__c FROM Dataset_Image__c WHERE Dataset__c IN: dataSetMap.keySet() AND Dataset_Image_Id__c = NULL];
        
        Map<EinsteinVision_Example, Dataset_Image__c> dataSetImageMap = new Map<EinsteinVision_Example, Dataset_Image__c>();
        
        for(Dataset_Image__c image : dataSetImages)
        {
            HttpResponse res = HttpHelper.Request('GET', image.Raw_Image__c, null, null);
            Blob imageBlob;
            
            if(res != null)
            {
                imageBlob = res.getBodyAsBlob();
            }
            
            long dataSetId = (long)dataSetMap.get(image.Dataset__c).Dataset__r.Dataset_Id__c;
            long dataSetLabelId = (long)dataSetMap.get(image.Dataset__c).Dataset_Label_Id__c;
            
            EinsteinVision_Example example = predictionService.createExample(dataSetId, image.Name, dataSetLabelId, imageBlob);
            
            if(example != null && example.id != null)
            {
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
    }*/
}