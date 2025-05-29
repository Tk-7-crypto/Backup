/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunityLineItems
 */
@isTest
public class TST_SLT_SiteSubmission {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Site_Submission__c siteSubmission = new Site_Submission__c();
        siteSubmission.Name = 'Test Site Submission';
        siteSubmission.Opportunity__c = opp.id;
        insert siteSubmission;
        
    }
    
    /**
     * This method used to Select OpportunityLineItems by opportunity id
     */    
    @IsTest
    static void testgetSiteSubmissionByOppId() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<String> fieldsToQuery = new Set<String>{'id','Status__c','Opportunity__c','PSV_Scheduled_for__c','Site_Selection_Notification__c'};
        List<Site_Submission__c> siteSubmissionToOppList = new List<Site_Submission__c>();
        Test.startTest();
		    siteSubmissionToOppList = new SLT_SiteSubmission().getSiteSubmissionByOppId(new Set<Id> { opp.Id }, fieldsToQuery);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = siteSubmissionToOppList.size();
        System.assertEquals(expected, actual);
	}
    
    @IsTest
    static void testGetSiteSubmissionById() {
        Site_Submission__c siteSubmission = [Select id from Site_Submission__c LIMIT 1];
        Set<String> fieldsToQuery = new Set<String>{'id','Name'};
        List<Site_Submission__c> siteSubmissionToOppList = new List<Site_Submission__c>();
        
        Test.startTest();
		    siteSubmissionToOppList = new SLT_SiteSubmission().getSiteSubmissionById(new Set<Id> { siteSubmission.Id }, fieldsToQuery);
        Test.stopTest();
        
        System.assertEquals(1, siteSubmissionToOppList.size(), 'Site Submission Record should returned');
	}
}