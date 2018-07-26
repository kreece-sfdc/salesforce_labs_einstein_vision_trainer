public class AuthCallBack implements Metadata.DeployCallback 
{
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) 
    {
        if (result.status == Metadata.DeployStatus.Succeeded) 
        {
            EventHelper.PublishAuthEvent(Constants.Unsplash, Constants.Auth_Deploy_Success);
        } 
        else 
        {
            EventHelper.PublishAuthEvent(Constants.Unsplash, Constants.Auth_Deploy_Failure);
        }
    }
}