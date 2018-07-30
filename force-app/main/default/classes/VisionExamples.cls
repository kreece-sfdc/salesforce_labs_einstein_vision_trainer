public with sharing class VisionExamples
{
    public static List<Vision.Prediction> CallVisionUrl() 
    {
        // Get a new token
        string access_token = AuthHelper.GetVisionAccessToken();
        
        // Make a prediction using URL to a file
        return Vision.predictUrl('https://img.gta5-mods.com/q95/images/ferrari-430-scuderia-add-on-replace-tuning-template/27acec-GTA5%2023-11-2016%2020-48-06-473.jpg',access_token,'GeneralImageClassifier');
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