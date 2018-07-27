public with sharing class VisionExamples
{
    public static List<Vision.Prediction> CallVisionUrl() 
    {
        // Get a new token
        string access_token = AuthHelper.GetVisionAccessToken();
        
        // Make a prediction using URL to a file
        return Vision.predictUrl('https://einstein.ai/images/generalimage.jpg',access_token,'GeneralImageClassifier');
    }

    public static List<Vision.Prediction> CallVisionContent() 
    {
        // Get a new token
        string access_token = AuthHelper.GetVisionAccessToken();

        // Make a prediction for an image stored in Salesforce
        // by passing the file as blob which is then converted to base64 string
        ContentVersion content = [SELECT Title,VersionData FROM ContentVersion where Id = '06841000000LkfCAAS' LIMIT 1];
        return Vision.predictBlob(content.VersionData, access_token, 'GeneralImageClassifier');
    }
}