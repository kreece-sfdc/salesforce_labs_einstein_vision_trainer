public with sharing class Upload_ImageController {
    @AuraEnabled
    public static string PushToCustomObject(String fileName, String documentId)
    {
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = [SELECT Id FROM ContentVersion WHERE ContentDocumentId=:documentId].Id;
        insert cd;

        Image_Classification__c  ic = new Image_Classification__c();
        // what is the status expected?
        ic.Status__c = filename+' Uploaded';
        // need to retrieve public link sharing here
        ic.Url__c	= [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId=:cd.ContentVersionId].ContentDownloadUrl;
        Insert Ic;

        return null;
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
}