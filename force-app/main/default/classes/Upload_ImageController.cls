public with sharing class Upload_ImageController {
    @AuraEnabled
    public static string PushToCustomObject(String fileName, String documentId)
    {
        Image_Classification__c  Ic = new Image_Classification__c();

        // what is the status expected?
        Ic.Status__c = filename+' Uploaded';
        // need to retrieve public link sharing here
        Ic.Url__c	= '/r/ContentDocument/'+documentId+'/view';

        Insert Ic;

        return null;
    }
}