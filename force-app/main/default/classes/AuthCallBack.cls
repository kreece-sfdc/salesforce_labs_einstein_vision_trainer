public class AuthCallBack implements Metadata.DeployCallback 
{
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) 
    {
        
        if (result.status == Metadata.DeployStatus.Succeeded) 
        {
            //BotDataHelper.PublishEvent(BotDataConstants.Type_Fitbit, BotDataConstants.Message_Deploy_Successful);
        } 
        else 
        {
            //BotDataHelper.PublishEvent(BotDataConstants.Type_Fitbit, BotDataConstants.Message_Deploy_Failed);
        }
    }
}