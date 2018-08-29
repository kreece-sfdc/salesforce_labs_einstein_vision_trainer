public with sharing class Pinterest_AuthController 
{
    public string Code { get; set; }
    
	public PageReference Redirect()
    {
        if(!ApexPages.currentPage().getParameters().containsKey('code'))
        {
            PageReference pr = new PageReference(AuthHelper.GenerateAuthUrl('https://api.pinterest.com/oauth/?', '4979754444963985207', 'dc79fc4c92ea847b43df6d4545f3aa701e837d43b9d9534ff51cfc3ac5156b9e', 'https%3A%2F%2Ftest.salesforce.com%2Fapex%2Fpinterest_auth', 'read_public'));
            pr.setRedirect(true);
            return pr;
        }
        else
        {
            Code = ApexPages.currentPage().getParameters().get('code');
            AuthHelper.GetAccessToken('https://api.pinterest.com/v1/oauth/token?', '4979754444963985207', 'dc79fc4c92ea847b43df6d4545f3aa701e837d43b9d9534ff51cfc3ac5156b9e', 'https%3A%2F%2Ftest.salesforce.com%2Fapex%2Fpinterest_auth', Code, Constants.Pinterest);
        }
        
        return null;
    }
}