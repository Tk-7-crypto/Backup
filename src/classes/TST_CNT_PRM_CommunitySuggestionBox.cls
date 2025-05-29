@IsTest
public class TST_CNT_PRM_CommunitySuggestionBox {

    static testMethod void testSendSuggetionEmail(){
        PRM_BaseUrl__c prmBaseURL = PRM_BaseUrl__c.getOrgDefaults();
        prmBaseURL.PRM_Org_Base_Url__c = 'https://test.com';
        prmBaseURL.PRM_Partner_Portal_URL__c = 'https://test.com';
        prmBaseURL.Suggestion_Receiver_Email__c = 'test@iqvia.com';
        upsert prmBaseURL;
        
        CNT_PRM_CommunitySuggestionBox.sendSuggetionEmail('test subject', 'test body'); 
    }
}