public with sharing class Upload_ImageController 
{
    @AuraEnabled
    public static Id PushToCustomObject(String fileName, String documentId, string model)
    {
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = [SELECT Id FROM ContentVersion WHERE ContentDocumentId=:documentId].Id;
        insert cd;

        Image_Classification__c  ic = new Image_Classification__c
            (
		        Status__c = 'Uploaded',
	    	    Url__c	= [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId=:cd.ContentVersionId].ContentDownloadUrl,
                Classifier__c = model
            );
        insert ic;

        EventHelper.PublishClassificationEvent(ic.Id, Constants.Classification_Created);
        
        return ic.Id;
    }
    
    @AuraEnabled
    public static List<Image_Classification_Result__c> GetResults(Id classificationId)
    {
        return [SELECT Label__c, Result__c FROM Image_Classification_Result__c WHERE Image_Classification__c =: classificationId];
    }
    
    @AuraEnabled
    public static List<Dataset__c> GetModels()
    {
        return [SELECT Id, Name, Model_Id__c FROM Dataset__c WHERE Id != NULL];
    }

    @AuraEnabled
    public static string CreateRecordId(String recordId)
    {
        List<Account> accs=[Select Id,Name from Account where Name = 'Tmp'];
    
        if (accs.size() <= 0)
        {
            Account  acc = new Account();
            // create temporary Record
            acc.Name = 'Tmp';
            Insert acc;
            return acc.Id;
        }
        return accs[0].Id;
    }
    
    @AuraEnabled
    public static String getSessionId() 
    {
        return UserInfo.getSessionId();
    }
}