public class ImageWrapper 
{
    @AuraEnabled
    public string Description { get; set; }
    @AuraEnabled
    public string Url { get; set; }
    @AuraEnabled
	public boolean Selected { get; set; }
}