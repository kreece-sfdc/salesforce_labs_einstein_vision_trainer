public class DeployMetadata 
{
    public static void Deploy(Metadata.CustomMetadata md) 
    {
        AuthCallBack callback = new AuthCallBack();
        
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        container.addMetadata(md);
        
        if(!Test.isRunningTest())
        {
        	Metadata.Operations.enqueueDeployment(container, callback);
        }
    }
}