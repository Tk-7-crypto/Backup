@isTest
public class TST_CNT_CRM_CreateNewSiteSubmission {
    
    @isTest
    public static void testCreateSiteSubmissionRecords(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        LoadCRMSampleData.createAvacareSetup();
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        String siteIds = '';
        for(Account dp: [SELECT id FROM Account WHERE (Parent.Name = 'Avacare' AND Type__c like '%Clinical Site%')]){
            siteIds += dp.Id +',';
        }
        siteIds.removeEnd(',');
        
        Test.startTest();
        
        Boolean result = CNT_CRM_CreateNewSiteSubmission.createSiteSubmissionRecords(siteIds, opp.Id);
        List<Site_Submission__c> sss = [SELECT Id FROM Site_Submission__c];
        System.assertEquals(true, sss.size() > 0);
        Test.stopTest();
    }
    
}