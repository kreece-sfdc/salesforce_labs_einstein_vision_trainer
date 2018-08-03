public with sharing class Notifier_Controller 
{
	@AuraEnabled
    public static String getSessionId() 
    {
        return UserInfo.getSessionId();
    }
}