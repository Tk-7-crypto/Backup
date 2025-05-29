/*
* Test class for FLOW - IG_FL01_OWF_SendEmailNotification
  IQVIAPSA-7228
*/
@isTest
public class TST_IG_FL01_OWF_SendEmailNotification {
@testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        RecordType IQVIAUserRecordtType = [SELECT DeveloperName, id from RecordType where DeveloperName = 'IQVIA_User_Contact' limit 1];
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.recordTypeId = IQVIAUserRecordtType.id;
        cont.pse__Is_Resource_Active__c = true;
        cont.EmployeeNumber__c ='122';
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'IG-Lead';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;

        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
       
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Total_Bid_Value_Labor_Direct_Discount__c = 1000;
        bidHistory.Bid_Sent_Date__c = Date.Today().addDays(-1);
        bidHistory.Bid_Sent__c = 'Yes';
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Final_Number_of_Scenarios__c  = 2;
        bidHistory.Additional_Explanation__c = 'test';
        bidHistory.Pricing_Under_MSA__c = 'Yes';
        bidHistory.Link_to_Budget_Files__c = 'test';
        bidHistory.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        insert bidHistory;
        
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
    }
    
    @isTest
    static void testScheduledEmail(){
        Bid_History__c bidHistory =[Select id from Bid_History__c limit 1];
        Investigator_Grant__c investigatorGrantRecord = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(bidHistory.id);
        Test.startTest();
        insert investigatorGrantRecord;
        Test.stopTest();
        List<Investigator_Grant__c> igList = [Select id,Assigned_Investigator_Grants_Developer__c from Investigator_Grant__c where Bid_History__c =:bidHistory.id limit 1];
        Integer expected = 1;
        System.assertEquals(expected, igList.size());
    }
}