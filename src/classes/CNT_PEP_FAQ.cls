/*
* Version       : 1.0
* Description   : Apex Controller for LXC_PEP_FAQ component.
*/
public with sharing class CNT_PEP_FAQ {
    
    @AuraEnabled
    public static List<PRM_FAQ_Articles__c> getFAQArticles()
    {
        return new SLT_PRM_FAQ_Articles().getFAQArticles();
    }

}