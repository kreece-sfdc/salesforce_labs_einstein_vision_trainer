public with sharing class UnSplash_AuthController 
{
    public string Code { get; set; }
    
	public PageReference Redirect()
    {
        if(!ApexPages.currentPage().getParameters().containsKey('code'))
        {
            PageReference pr = new PageReference(AuthHelper.GenerateAuthUrl('https://unsplash.com/oauth/authorize?', '7ef8039b7e97925e60e489fd7b4759a4539ee07b79fb5ee929f8674b89b098d6', 'e1ae19b1c308f288a39431150ca8a33fb46cf21fb3f3796c15655a572eeb84fb', 'https%3A%2F%2Ftest.salesforce.com%2Fapex%2Funsplash_auth', 'public'));
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            Code = ApexPages.currentPage().getParameters().get('code');
            AuthHelper.GetAccessToken('https://unsplash.com/oauth/token?', '7ef8039b7e97925e60e489fd7b4759a4539ee07b79fb5ee929f8674b89b098d6', 'e1ae19b1c308f288a39431150ca8a33fb46cf21fb3f3796c15655a572eeb84fb', 'https%3A%2F%2Ftest.salesforce.com%2Fapex%2Funsplash_auth', Code, Constants.Unsplash);
        }
        
        return null;
    }
}