/**
* This test class is used to test all methods in Investigator grant trigger helper.
* version : 1.0
*/
@isTest(seeAllData=false)public class TST_DAOH_OWF_Investigator_Grant {
       /**
* This method is used to setup data for all methods.
*/
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
        Test.startTest();
        
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'IG-Lead';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
        
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        
        pse__Assignment__c assignment =  UTL_OWF_TestData.createAssignmentForBidHistory(bidHistory.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignment;
        
        assignment.pse__Status__c ='Accepted';
        update assignment;
        Test.stopTest();
        
        
    }
    
     @isTest
    static void testPopulateAssignedInvestigator() {
        Bid_History__c bidHistory =[Select id from Bid_History__c limit 1];
        Test.startTest();
        Investigator_Grant__c investigatorGrantRecord = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(bidHistory.id);
        insert investigatorGrantRecord; 
        Test.stopTest();
        pse__Assignment__c assignment =[Select id,pse__Resource__r.pse__Salesforce_User__c from pse__Assignment__c where Subgroup_Name__c ='IG-Lead' and Bid_History__c =: bidHistory.id limit 1];
        Investigator_Grant__c igRecord = [Select id,Assigned_Investigator_Grants_Developer__c from Investigator_Grant__c where Bid_History__c =:bidHistory.id limit 1];
        System.assertEquals(assignment.pse__Resource__r.pse__Salesforce_User__c,igRecord.Assigned_Investigator_Grants_Developer__c, 'Verify if IG-Lead resource is assigned on investigator grant record');
    }
    

}