public with sharing class Unsplash_GridController 
{ 
    @AuraEnabled
    public static Map<string, object> TrainDataset(Id dataSetId)
    {
        Dataset__c dataSet = [SELECT Id, Name, Dataset_Id__c, Model_Id__c FROM Dataset__c WHERE Id =: dataSetId LIMIT 1];
        
        if(dataSet != null)
        {
            
            EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
            Map<string, object> modelResult = service.trainDataset((long)dataSet.Dataset_Id__c, dataSet.Name, 0, 0, '{ "withFeedback": true }');
            
            if(modelResult != null)
            {
                dataSet.Model_Id__c = (string)modelResult.get('modelId');
                upsert dataSet;
                
                if((string)modelResult.get('status') == 'QUEUED')
                {
                	EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Queued);
                }
                else if((string)modelResult.get('status') == 'RUNNING')
                {
                    EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Started);
                }
                else if((string)modelResult.get('status') == 'SUCCEEDED')
                {
                    EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Succeeded);
                }
                else if((string)modelResult.get('status') == 'FAILED')
                {
                    EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Training_Failed);
                }
                
                return modelResult;
            }
            
        }
        
        return null;
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
                return modelResult;
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Id CreateDataset(Id dataSetId, Id dataSetLabelId, string name, string label, string itemsString)
    {
        List<object> items = (List<object>)JSON.deserializeUntyped(itemsString);
        List<Dataset_Image__c> dataSetImages = new List<Dataset_Image__c>();
        
        if(dataSetId == null)
        {
            Dataset__c dataSet = new Dataset__c
                (
                    Name = name
                );
            insert dataSet;
            
            dataSetId = dataSet.Id;
            
            Dataset_Label__c dataSetLabel = new Dataset_Label__c
                (
                    Dataset__c = dataSet.Id,
                    Name = label
                );
            insert dataSetLabel;
            dataSetLabelId = dataSetLabel.Id;
        }
        else if(dataSetLabelId == null)
        {
            Dataset_Label__c dataSetLabel = new Dataset_Label__c
                (
                    Dataset__c = dataSetId,
                    Name = label
                );
            insert dataSetLabel;
            dataSetLabelId = dataSetLabel.Id;
        }
        
        for(object item : items)
        {
            Map<string, object> itemMap = (Map<string, object>)item;
            
            if((boolean)itemMap.get('Selected') == true)
            {
                Dataset_Image__c dataSetImage = new Dataset_Image__c
                    (
                        Dataset__c = dataSetId,
                        Dataset_Label__c = dataSetLabelId,
                        Raw_Image__c = (string)itemMap.get('RawUrl')
                    );
                
                dataSetImages.add(dataSetImage);
            }
        }
        
        if(!dataSetImages.isEmpty())
        {
            insert dataSetImages;
        }
        
        EventHelper.PublishDatasetEvent(dataSetId, Constants.Dataset_Created);
        
        return dataSetId;
    }
    
    @AuraEnabled
    public static List<Dataset__c> GetDatasets(boolean hasDataSetId)
    {
        if(hasDataSetId == true)
        {
            return [SELECT Id, Name, Dataset_Id__c FROM Dataset__c WHERE Dataset_Id__c != null];
        }
        
        return [SELECT Id, Name FROM Dataset__c WHERE Id != null];
    }
    
    @AuraEnabled
    public static List<Dataset_Label__c> GetDatasetLabels(Id dataSetId)
    {
        return [SELECT Id, Name FROM Dataset_Label__c WHERE Dataset__c =: dataSetId];
    }
    
    @AuraEnabled
    public static List<ImageWrapper> SearchUnsplash(string query, decimal page_number)
    {
        if(page_number == null) 
        {
            page_number = 1;
        }
        
        Map<string, object> results = Unsplash_Helper.QueryPhotos(AuthHelper.ReadAccessToken(Constants.Unsplash), query, page_number);
        
        return Unsplash_Helper.GetImages(results, page_number);
    }
    
    @AuraEnabled
    public static string ImageSelection(ImageWrapper[] items)
    {
        return null;
    }
    
    @AuraEnabled
    public static boolean HasAccessToken()
    {
        return AuthHelper.HasAccessToken(Constants.Unsplash);
    }
    
    @AuraEnabled
    public static string GetAuthUrl()
    {
        string login_url = AuthHelper.GetLoginUrl();
        
        return AuthHelper.GenerateAuthUrl('https://unsplash.com/oauth/authorize?', '7ef8039b7e97925e60e489fd7b4759a4539ee07b79fb5ee929f8674b89b098d6', 'e1ae19b1c308f288a39431150ca8a33fb46cf21fb3f3796c15655a572eeb84fb', 'https%3A%2F%2F' + login_url + '.salesforce.com%2Fapex%2Funsplash_auth', 'public');
    }
    
    @AuraEnabled
    public static String getSessionId() 
    {
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    public static void PushToast(Id dataSetId, string action) 
    {
        EventHelper.PublishDatasetEvent(dataSetId, action);
    }
}