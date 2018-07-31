public class ImageWrapper 
{
    @AuraEnabled
    public Integer ImgId { get; set; }
    @AuraEnabled
    public string Description { get; set; }
    @AuraEnabled
    public string Url { get; set; }
    @AuraEnabled
	public boolean Selected { get; set; }
    @AuraEnabled
	public string RawUrl { get; set; }
    @AuraEnabled
	public string Photographer { get; set; }
    @AuraEnabled
	public string PhotographerSocial { get; set; }
}