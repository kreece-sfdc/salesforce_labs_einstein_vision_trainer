public with sharing class AuthHelper 
{
	public static string GenerateAuthUrl(string url, string client_id, string client_secret, string callback_url, string scope)
    {
        List<string> parts = new List<string>{ url };
        parts.add('response_type=code');
        parts.add('client_id=' + client_id);
        parts.add('client_secret=' + client_secret);
        parts.add('redirect_uri=' + callback_url);
        parts.add('scope=' + scope);
        
		return string.join(parts, '&');
    }
    
    public static boolean HasAccessToken(string storage)
    {
        List<Auth_Storage__mdt> auths = [SELECT Access__c FROM Auth_Storage__mdt WHERE MasterLabel =: storage + '_' + UserInfo.getUserId()];
        
        if(!auths.isEmpty())
        {
           return true;
        }

        return false;
    }
    
    public static string ReadAccessToken(string storage)
    {
        List<Auth_Storage__mdt> auths = [SELECT Access__c FROM Auth_Storage__mdt WHERE MasterLabel =: storage + '_' + UserInfo.getUserId()];
        
        if(!auths.isEmpty())
        {
            Auth_Storage__mdt auth = auths.get(0);
            return auth.Access__c;
        }

        return null;
    }
    
    public static string GetVisionAccessToken()
    {
        List<Auth_Storage__mdt> auths = [SELECT Access__c FROM Auth_Storage__mdt WHERE MasterLabel =: Constants.Einstein_Vision];
        
        if(!auths.isEmpty())
        {
            Auth_Storage__mdt auth = auths.get(0);
            return auth.Access__c;
        }

        return null;
    }
    
    public static void GetAccessToken(string url, string client_id, string client_secret, string callback_url, string code, string storage)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        
        List<string> parts = new List<string>();
        parts.add('client_id='+ client_id);
        parts.add('client_secret='+ client_secret);
        parts.add('grant_type=authorization_code');
        parts.add('redirect_uri=' + callback_url);
        parts.add('code=' + code);
        req.setBody(string.join(parts, '&'));
        
        Http api = new Http();
        HttpResponse res = api.send(req);
        system.debug(res.getStatusCode());
        system.debug(res.getBody());
        
        if(res.getStatusCode() == 200)
        {
        	Map<string, object> resMap = (Map<string, object>)JSON.deserializeUntyped(res.getBody());
            
            string refresh_token = (string)resMap.get('refresh_token');
            string access_token = (string)resMap.get('access_token');
            
            WriteAccessToken(storage, access_token, refresh_token);
        }
    }
    
    public static void WriteAccessToken(string storage, string access_token, string refresh_token)
    {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Auth_Storage.' + storage + '_' + UserInfo.getUserId();
        customMetadata.label = storage + '_' + UserInfo.getUserId();
        
        Metadata.CustomMetadataValue accessField = new Metadata.CustomMetadataValue();
        accessField.field = 'Access__c';
        accessField.value = access_token;
        customMetadata.values.add(accessField);
        
        Metadata.CustomMetadataValue refreshField = new Metadata.CustomMetadataValue();
        refreshField.field = 'Refresh__c';
        refreshField.value = refresh_token;
        customMetadata.values.add(refreshField);
        
        DeployMetadata.Deploy(customMetadata);
    }
    
    /*public static void GetAccessTokenFromRefresh(string url, string refresh_token)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Basic ' + auth);

        List<string> parts = new List<string>();
        parts.add('grant_type=refresh_token');
        parts.add('refresh_token=' + refresh_token);
        req.setBody(string.join(parts, '&'));
        
        Http api = new Http();
        HttpResponse res = api.send(req);
        
        if(res.getStatusCode() == 200)
        {
        	Map<string, object> resMap = (Map<string, object>)JSON.deserializeUntyped(res.getBody());
            
            string access_token = (string)resMap.get('access_token');
            
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'Auth_Storage.' + storage + '_' + UserInfo.getUserId();
            customMetadata.label = storage;
            
            Metadata.CustomMetadataValue accessField = new Metadata.CustomMetadataValue();
            accessField.field = 'Access__c';
            accessField.value = access_token;
            customMetadata.values.add(accessField);
            
            DeployMetadata.Deploy(customMetadata);
        }
    }*/
}