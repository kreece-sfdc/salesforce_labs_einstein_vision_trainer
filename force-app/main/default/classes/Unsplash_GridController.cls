public with sharing class Unsplash_GridController 
{ 
	@AuraEnabled
    public static List<ImageWrapper> SearchUnsplash(string query, integer page_number)
    {
        if(page_number==null) 
              page_number =1;
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
        return AuthHelper.GenerateAuthUrl('https://unsplash.com/oauth/authorize?', '7ef8039b7e97925e60e489fd7b4759a4539ee07b79fb5ee929f8674b89b098d6', 'e1ae19b1c308f288a39431150ca8a33fb46cf21fb3f3796c15655a572eeb84fb', 'https%3A%2F%2Ftest.salesforce.com%2Fapex%2Funsplash_auth', 'public');
    }
    
    @AuraEnabled
    public static String getSessionId() {
      return UserInfo.getSessionId();
    }
}