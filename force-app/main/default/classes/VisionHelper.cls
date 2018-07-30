public with sharing class VisionHelper 
{
	public static void CreateDataset(string name, List<string> labels)
    {
        /*string url = 'https://api.einstein.ai/v2/vision/datasets';
        string params = 'name:' + name;
        params += '\r\nlabels:' + string.join(labels, ',');
        params += '\r\ntype:image';
        
        Map<string, string> headers = new Map<string, string>();
        headers.put('Authorization', 'Bearer ' + AuthHelper.GetVisionAccessToken());
        headers.put('Content-Type', 'multipart/form-data');
        
        HttpResponse res = HttpHelper.Request('POST', url, headers, params);

        
        Map<string, object> results = (Map<string, object>)JSON.deserializeUntyped(res.getBody());
        
        string id_val = (string)results.get('id');
        string statusMsg = (string)results.get('statusMsg');
        
        Map<string, object> labelSummary = (Map<string, object>)results.get('labelSummary');
        List<object> labels_val = (List<object>)labelSummary.get('labels');
        
        Dataset__c ds = new Dataset__c
            (
                Name = name
            );
        
        insert ds;
       
        List<Dataset_Label__c> dsLabels = new List<Dataset_Label__c>();
        
        for(object labelObj : labels_val)
        {
            Map<string, object> label = (Map<string, object>)labelObj;
            
            string labelId = (string)label.get('id');
            string labelName = (string)label.get('name');
            
            Dataset_Label__c dsLabel = new Dataset_Label__c
                (
                    Name = labelName,
                    Dataset_Label_Id__c = labelId,
                    Dataset__c = ds.Id
                );
            
            dsLabels.add(dsLabel);
        }
        
        if(!dsLabels.isEmpty())
        {
            insert dsLabels;
        }*/
    }
}