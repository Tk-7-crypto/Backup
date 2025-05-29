@isTest
private class TST_BidHistoryWrapper {
    
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;  
        OWF_Config__c owfConfig = UTL_OWF_TestData.setupOWFConfig(grp.Id);
        owfConfig.OWF_Compatible_Group_Set_1__c = 'TSL';
        owfConfig.OWF_Compatible_Group_Set_2__c = 'TSL';
        owfConfig.OWF_Compatible_Group_Set_3__c = 'TSL';
        owfConfig.OWF_Compatible_Group_Set_4__c = 'TSL';
        owfConfig.OWF_Compatible_Group_Set_5__c = 'TSL';
        owfConfig.OWF_Compatible_Group_Set_6__c = 'TSL';
        insert owfConfig;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.Secondary_Sub_Group__c = 'TSL';
        insert cont;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        User testUser = new User(Id = UserInfo.getUserId());
        testUser.SUBREGION__c = 'United States of America';
        testUser.EmployeeNumber = '87876567';
        update testUser;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Not Sure';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Owner = testUser;
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        test.startTest();
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        rrList.add(resourceRequest);
        insert rrList;
        
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.id, bidProject.id, null, cont.id, resourceRequest.id);
        assignmentList.add(assignment);
        insert assignmentList;
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        /*resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'TAL',
            Sub_Group__c = 'TAL',
            Name = 'TAL'
        ));*/
        insert resourceToSubGroupSettingList;
        pse__Proj__c daysOffProject = UTL_OWF_TestData.createBidProject(grp.Id);
        daysOffProject.name = 'Annual Leave/Vacation';
        insert daysOffProject;
        test.stopTest();
    }
    
    @isTest
    private static void testBidWrapper() {
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        List<User> testUser1 = UTL_TestData.createUser('System Administrator', 1);
        testUser1[0].IsActive = true;
        insert testUser1[0];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
        bidHistory.Requested_Agreement_Type__c = CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER;
        bidHistory.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;IQB Ongoing DM;IQB Project Management;IQB Site Contracts;RNPS';
        insert bidHistory;
        
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(9);
        agreement1.Requested_Agreement_Type__c = CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER;
        agreement1.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;IQB Ongoing DM;IQB Project Management;IQB Site Contracts;RNPS';
        insert agreement1;
        Test.stopTest();
        
        List<BidHistoryWrapper> wrapperList = new List<BidHistoryWrapper>();
        BidHistoryWrapper bid = new BidHistoryWrapper();
        bid.SObjectName = 'Quote';
        bid.bidHistoryId = bidHistory.id;
        bid.plannedExecutionDate = System.today();
        wrapperList.add(bid);
        BidHistoryWrapper bidRecord = new BidHistoryWrapper();
        bidRecord.SObjectName = 'Apttus__APTS_Agreement__c';
        bidRecord.bidHistoryId = agreement1.id;
        bidRecord.statusCategory = CON_OWF.OWF_STATUS_CANCELLED;
        bidRecord.agreementPlannedExecutionDate = Date.today().addDays(9);
        wrapperList.add(bidRecord);
        String str = UTL_OWF.updateContractPostAwardbidFromOtherObject(wrapperList);
        
        Bid_History__c bid1 = [Select id, Bid_Due_Date__c from Bid_History__c Where id =: bidHistory.id];
        System.assertEquals(System.today(), bid1.Bid_Due_Date__c, 'Success'); 
    }

}
