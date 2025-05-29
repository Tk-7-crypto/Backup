@isTest
public with sharing class TST_CNT_QueableClass {
    @testSetup
    public static void setup(){
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'CA&S',
            Sub_Group__c = 'CP&A-CA&S',
            Name = 'CA&S'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'ASL',
            Sub_Group__c = 'Analytics Strategy Lead',
            Name = 'ASL'
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
        System.debug('bidHistory ' + bidHistory.Id);
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
        
    }
    static testmethod  void testQuableMethodForFolderCreation(){
        Bid_History__c bidHistory = [SELECT id, Bid_History_Related_Opportunity__c from Bid_History__c Limit 1];
        Test.startTest(); 
            System.enqueueJob(new CNT_BOX_QueuableFolderCreation(bidHistory.Id, bidHistory.Bid_History_Related_Opportunity__c, 'Bid History'));
        Test.stopTest();         
    } 
}