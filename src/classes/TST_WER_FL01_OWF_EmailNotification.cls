/*
* Test class for FLOW- WER_FL01_OWF_EmailNotification
*/
@IsTest
public class TST_WER_FL01_OWF_EmailNotification {
    
    @testSetup
    static void dataSetup() {
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        
        insert resourceToSubGroupSettingList;
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
    }
    
    @IsTest
    static void testsendEmailToRequestedProductsEmailsOnCSSBid() 
    {
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'PCS';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_01_SendEmailForCSSBidBasedOnProductsSelected';
        resourceToSubGroupSettingList.Key__c = 'Complete Consent';
        resourceToSubGroupSettingList.Value__c = 'vikas.soni@metacube.com,ronak.kumpawat@metacube.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.PCS__c = True;
        bidHistory.Bid_Category__c = 'Combined';
        bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory.Estimated_Fees__c = 'Greater than $20M';
        bidHistory.LPI_Date__c = System.today();
        bidHistory.DBL_Date__c = System.today();
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Requested_Services__c = 'CD - ECG';
        bidHistory.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory.OWF_Potential_Regions__c = 'Latin America';
        Test.startTest();
        	insert bidHistory;
            system.assertEquals(2, bidHistory.Number_of_Scenarios__c, 'Success');
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(1, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
    }
}