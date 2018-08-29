public with sharing class HttpHelper 
{
	public static HttpResponse Request(string method, string url, Map<string, string> headers, string body)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(url);
        
        if(headers != null)
        {
            for(string header : headers.keySet())
            {
                req.setHeader(header, headers.get(header));            
            }
        }
        
        if(body != null && !string.isEmpty(body))
        {
            req.setBodyAsBlob(blob.valueOf(body));
        }

        Http api = new Http();
        HttpResponse res = api.send(req);
        
        return res;
    }
}