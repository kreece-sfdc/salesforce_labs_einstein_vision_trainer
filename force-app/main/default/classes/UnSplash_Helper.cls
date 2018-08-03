public with sharing class UnSplash_Helper 
{
	public static Map<string, object> QueryPhotos(string access_token, string query, decimal page)
    {
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://api.unsplash.com/search/photos?page=' + page + '&per_page=10&query=' + query);
        req.setHeader('Authorization', 'Bearer ' + access_token);

    
        Http api = new Http();
        HttpResponse res = api.send(req);
        
        Map<string, object> ret = new Map<string, object>();
        
        if(res.getStatusCode() == 200)
        {
        	ret = (Map<string, object>)JSON.deserializeUntyped(res.getBody()); 
        }
        
        return ret;
    }
    
    public static List<ImageWrapper> GetImages(Map<string, object> queryResults, decimal pager)
    {
        List<ImageWrapper> items = new List<ImageWrapper>();
        
        List<object> results = (List<object>)queryResults.get('results');

        decimal imgId = (pager-1)*10;
        
        for(object obj : results)
        {
            Map<string, object> mapItem = (Map<string, object>)obj;
        
            string description = (string)mapItem.get('description');
            
            Map<string, object> urls = (Map<string, object>)mapItem.get('urls');
            string raw = (string)urls.get('regular');
            string small = (string)urls.get('small');
            
            Map<string, object> userSec = (Map<string, object>)mapItem.get('user');
			string name = (string)userSec.get('name');
            string portfolio_url = (string)userSec.get('portfolio_url');
            
			ImageWrapper item = new ImageWrapper();
    
            item.ImgId = (integer)imgId++;
            item.Description = description;
            item.Url = small;
            item.RawUrl = raw;
            item.Photographer = name;
            item.PhotographerSocial = portfolio_url;
            item.Selected = false;
            
            items.add(item);
        }
        
        return items;
	}
}