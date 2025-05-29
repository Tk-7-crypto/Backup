/**
* This test class is used to test UTL_OWF class.
* version : 1.0 
*/
@isTest(seeAllData=false)
private class TST_UTL_OWF {
    
    /**
* This method is used to setup data for all methods.
*/
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
    
    /**
* This test method used to test SendMailOnException method.
*/ 
    @isTest
    static void testSendMailOnException()
    {
        test.startTest();
        String emailSubject = 'Test Email Subject';
        Map<Id, String> assignmentIdToErrorMessageMap = new Map<Id, String>();
        assignmentIdToErrorMessageMap.put(userInfo.getUserId(), 'Test Error Message');
        UTL_OWF.sendMailOnException('', assignmentIdToErrorMessageMap, emailSubject);
        Integer invocations = Limits.getEmailInvocations();
        
        test.stopTest(); 
        System.assertEquals(1, invocations, 'Verifying SendMailOnException Functionality');        
    }
    
    
    /**
* This test method used to test SendMailOnException method With User Ids.
*/  
    @isTest
    static void testSendMailOnExceptionWithUserIds(){
        test.startTest();
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_AcceptUnassignedAssignments');
        owfBatchConfig.User_Ids__c = userInfo.getUserId();
        insert owfBatchConfig;
        Map<Id, String> assignmentIdToErrorMessageMap = new Map<Id, String>();
        assignmentIdToErrorMessageMap.put(userInfo.getUserId(), 'Test Error Message');
        String emailSubject = 'Test Email Subject';
        UTL_OWF.sendMailOnException('BCH_OWF_AcceptUnassignedAssignments', assignmentIdToErrorMessageMap, emailSubject);
        Integer invocations = Limits.getEmailInvocations();
        test.stopTest(); 
        
        System.assertEquals(1, invocations, 'Verifying SendMailOnException Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_Scenario1_2()
    {
        test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        
        List<pse__Resource_Request__c> resourceRequestList = UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        test.stopTest();
        
        system.assertNotEquals(null, resourceRequestList.size(), 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioSNPProduct()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Potential_Regions__c = 'Global';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c = 'SPN Product Specialist' limit 1];
        Test.stopTest();
        
        String expected = 'SPN Product Specialist';
        String actual = rr[0].SubGroup__c;
        system.assertEquals(expected, actual, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioTsl()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Potential_Regions__c = 'Asia Pacific';
        update oppty; 
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        update agreement; 
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c = 'TSL' limit 1];
        Test.stopTest();
        
        String expected = 'TSL';
        String actual = rr[0].SubGroup__c;
        system.assertEquals(expected, actual, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioTsl_BidDefenceCancellation()
    {
        Test.startTest();
        pse__Skill__c skill = UTL_OWF_TestData.createSkills(CON_OWF.SKILL_NAME_STRATEGIC_ANALYTICS, CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY);
        insert skill;
        pse__Proj__c project = [Select id from pse__Proj__c Limit 1];
        Contact cont = [Select id, Sub_Group__c from Contact limit 1];
        cont.Sub_Group__c = 'TSL';
        update cont;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement.RFP_Ranking__c = '3';
        agreement.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
        update agreement;
        pse__Resource_Request__c resourceRequest = [Select Id From pse__Resource_Request__c where subGroup__c = 'TSL' limit 1];
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id,project.ID, schedule.Id, cont.Id,resourceRequest.ID);
        assignment.pse__Status__c = 'Accepted';
        insert assignment;
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        //oppty.Line_of_Business__c = 'Clintec';
        //oppty.Potential_Regions__c = 'Asia Pacific';
        //oppty.QI_Invited_to_Present__c = 'No';
        //update oppty;
 
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c, Is_Bid_Defense__c from pse__Resource_Request__c where SubGroup__c = 'TSL' limit 1];
        Test.stopTest();
        
        Boolean expected = False;
        Boolean actual = rr[0].Is_Bid_Defense__c;
        system.assertEquals(expected, actual, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioJapan_DSB_SNP()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';  
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement.Targeted_Countries__c = 'JP';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c = 'DSB-Clinical' limit 1];
        Test.stopTest();
        
        String expected = 'DSB-Clinical';
        String actual = rr[0].SubGroup__c;
        system.assertEquals(expected, actual, 'Verifying ProcessResRequestForInitialBids Functionality');      	
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioMedical()
    {
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        Test.startTest();
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Potential_Regions__c = 'Asia Pacific';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement.Targeted_Countries__c = 'JP';
        update agreement;    
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        List<pse__Resource_Request__c> resourceRequestList = UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        Test.stopTest();
        
        system.assertNotEquals(null, resourceRequestList.size(), 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioReBid() 
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact'][0];    
        pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Resources_Needed__c = 'MSL';
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
        agreement1.RFP_Ranking__c = '3';
        agreement1.Budget_Deliverable__c = 'Full Budget';
        agreement1.Requested_Services__c = 'CEVA';
        Test.startTest();
        insert agreement1;
        agreement1.Opportunity_Type__c = 'Price per Pt';
        agreement1.RFP_Ranking__c = '1';
        agreement1.Budget_Deliverable__c = 'Price per Patient Range';
        update agreement1;
        List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c, pse__Status__c, pse__Assignment__c   From pse__Resource_Request__c Where Bid_History__c = :agreement1.Id];
        pse__Proj__c project = [Select Id,pse__Group__c,Bid_History__c,pse__End_Date__c,CurrencyIsoCode,pse__Start_Date__c From pse__Proj__c Where Bid_History__c =: agreement1.Id limit 1];
        pse__Resource_Request__c resReq =  UTL_OWF_TestData.createResourceRequestForBidHistory(agreement1.Id, oppty.Id, project.Id);
        resReq.pse__Status__c = 'Assigned';
        resReq.pse__Resource__c = cont.ID;
        resReq.SubGroup__c = 'TSL-Japan';
        resReq.pse__Group__c = grp1.ID;
        insert resReq;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement1.Id, project.Id, schedule.Id, cont.Id, resReq.Id);
        assignment.pse__Status__c = 'Accepted';
        insert assignment;
        
        System.assert(true, resReqsList.size() > 0);
        
        pse__Resource_Request__c resReq1 =  UTL_OWF.cloneReBidResourceRequest(project,resReq);
        Test.stopTest();
        
        system.assertNotEquals(null, resReq1, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioReBid2() 
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact'][0];    
        pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Resources_Needed__c = 'MSL';
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
        agreement1.RFP_Ranking__c = '3';
        agreement1.Budget_Deliverable__c = 'Full Budget';
        agreement1.Requested_Services__c = 'CEVA';
        insert agreement1;
        agreement1.Opportunity_Type__c = 'Price per Pt';
        agreement1.RFP_Ranking__c = '1';
        agreement1.Budget_Deliverable__c = 'Price per Patient Range';
        update agreement1;
        List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c, pse__Status__c, pse__Assignment__c   From pse__Resource_Request__c Where Bid_History__c = :agreement1.Id];
        pse__Proj__c project = [Select Id,pse__Group__c,Bid_History__c,pse__End_Date__c,CurrencyIsoCode,pse__Start_Date__c From pse__Proj__c Where Bid_History__c =: agreement1.Id limit 1];
        pse__Resource_Request__c resReq =  UTL_OWF_TestData.createResourceRequestForBidHistory(agreement1.Id, oppty.Id, project.Id);
        resReq.pse__Status__c = 'Assigned';
        resReq.pse__Resource__c = cont.ID;
        resReq.SubGroup__c = 'TSL-Japan';
        resReq.pse__Group__c = grp1.ID;
        Test.startTest();
        insert resReq;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement1.Id, project.Id, schedule.Id, cont.Id, resReq.Id);
        assignment.pse__Status__c = 'Accepted';
        insert assignment;
        
        System.assert(true, resReqsList.size() > 0);
        Set<ID> opptyIdSet = new Set<ID>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        List<pse__Resource_Request__c> resRequestInsertList = UTL_OWF.processResRequestForInitialBids(opptyIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> resReqReBidList =  UTL_OWF.processResRequestForClinicalReBids(opptyIdSet,agrCondition,resRequestInsertList);
        Test.stopTest();
        
        system.assertNotEquals(null, resReqReBidList, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testCalculateComplexityScoreTotal() 
    {
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>(); 
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
            'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
            'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
                for(OWF_Resource_Setting__mdt rsCMT : new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(orsFieldSet)) {
                    resSettingIdToResSettingMap.put(rsCMT.Sub_Group__c,rsCMT);                                          
                }
        Opportunity oppty = [Select Id from Opportunity limit 1];
        Test.startTest();
        
        List<pse__Resource_Request__c> resourceRequestList = [Select id, SubGroup__c, Bid_History__c from pse__Resource_Request__c where Bid_History__c != null limit 1];
        Map<Id,Bid_History__c> mapAgreementBuId = new Map<Id,Bid_History__c>([Select Id, RFP_Ranking__c, Number_of_Requested_Services__c, 
                                                                              Bid_History_Related_Opportunity__c, Project_Ex_Number_of_Unique_Tables__c, Staffing_Number_of_Unique_Tables__c, Is_there_a_Client_Bid_Grid__c,
                                                                              Estimated_Fees__c, Re_Bid_Complexity__c, Number_of_Sites__c, Bid_Due_Date__c, Bid_History_Related_Opportunity__r.Number_of_Potential_Regions__c,
                                                                              Bid_History_Related_Opportunity__r.Potential_Regions__c, Bid_History_Related_Opportunity__r.Presentation_Date__c                                                                
                                                                              From Bid_History__c limit 100]);
        Bid_History__c bidHistory = mapAgreementBuId.values()[0];
        pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: bidHistory.Id limit 1];
        pse__Resource_Request__c resReq =  UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, oppty.Id, project.Id);
        resReq.SubGroup__c = 'TSL';
        insert resReq;
        resourceRequestList.add(resReq);
        pse__Resource_Request__c resReq1 =  UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, oppty.Id, project.Id);
        resReq1.SubGroup__c = 'GBO-Lead PD';
        insert resReq1;
        resourceRequestList.add(resReq1);
        pse__Resource_Request__c resReq2 =  UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, oppty.Id, project.Id);
        resReq2.SubGroup__c = 'GBO-RFI';
        insert resReq2;
        UTL_OWF.createScheduleFromResourceRequest(resReq2);
        pse__Resource_Request__c resReq3 =  UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, oppty.Id, project.Id);
        resReq3.SubGroup__c = 'GBO-Support PD';
        insert resReq3;
        UTL_OWF.createScheduleFromResourceRequest(resReq3);
        resourceRequestList.add(resReq2);
        List<pse__Resource_Request__c> updateResourceRequestList = UTL_OWF.calculateComplexityScoreTotal(mapAgreementBuId,resSettingIdToResSettingMap, resourceRequestList);
        Test.stopTest();
        
        system.assertNotEquals(0, updateResourceRequestList[0].Complexity_Score_Total__c, 'Verifying CalculateComplexityScoreTotal Functionality');
    }
    
    /*static testMethod void testCalculateComplexityScoreTotalForAgreement() 
    {
        Map<String,OWF_Resource_Setting__mdt> resSettingIdToResSettingMap = new Map<String,OWF_Resource_Setting__mdt>(); 
        Set<String> orsFieldSet = new Set<String>{'Id','Sub_Group__c', 'Estimated_Fees__c','Is_there_a_Client_Bid_Grid__c','Number_of_Sites__c',
            'Potential_Regions__c','Project_Ex_Number_of_Unique_Tables__c','Re_Bid_Complexity__c',
            'Requested_Services__c','RFP_Ranking__c','Staffing_Number_of_Unique_Tables__c','Country__c'};
                for(OWF_Resource_Setting__mdt rsCMT : new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(orsFieldSet)) {
                    resSettingIdToResSettingMap.put(rsCMT.Sub_Group__c,rsCMT);                                          
                }
        Test.startTest();
        
        List<pse__Resource_Request__c> resourceRequestList = [Select id, SubGroup__c, Bid_History__c, Agreement__c from pse__Resource_Request__c where Agreement__c != null limit 1];
        resourceRequestList[0].SubGroup__c = 'TSL';
        Map<Id,Apttus__APTS_Agreement__c> mapAgreementBuId = new Map<Id,Apttus__APTS_Agreement__c>([Select Id, RFP_Ranking__c, Number_of_Requested_Services__c, 
                                                                                                    Apttus__Related_Opportunity__c, Project_Ex_Number_of_Unique_Tables__c, Staffing_Number_of_Unique_Tables__c, Is_there_a_Client_Bid_Grid__c,
                                                                                                    Estimated_Fees__c, Re_Bid_Complexity__c, Number_of_Sites__c, Bid_Due_Date__c, Apttus__Related_Opportunity__r.Number_of_Potential_Regions__c,
                                                                                                    Apttus__Related_Opportunity__r.Potential_Regions__c, Apttus__Related_Opportunity__r.Presentation_Date__c                                                                
                                                                                                    From Apttus__APTS_Agreement__c]);
        update resourceRequestList;
        List<pse__Resource_Request__c> updateResourceRequestList = UTL_OWF.calculateComplexityScoreTotal(mapAgreementBuId,resSettingIdToResSettingMap, resourceRequestList);
        Test.stopTest();
        
        system.assertNotEquals(0, updateResourceRequestList[0].Complexity_Score_Total__c, 'Verifying CalculateComplexityScoreTotalForAgreement Functionality');
    }*/
    @isTest
    static void testIsOPPhasOWFAgreement(){
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Test.startTest();
        Set<Id> isOWFAgreementSet = UTL_OWF.isOPPhasOWFAgreementReturnSet(new Set<Id> {oppty.Id});
        Test.stopTest();
        
        system.assertNotEquals(0 , isOWFAgreementSet.size(), 'Verifying IsOPPhasOWFAgreement Functionality');
    }
    
    @isTest
    static void testIsLoginUserhasPermissionControl(){
        Test.startTest();
        Boolean isPCExist = UTL_OWF.isLoginUserhasPermissionControl();
        Test.stopTest();
        
        System.assertEquals(true, isPCExist, 'The result should be true');
    }
    
    @isTest
    static void testCreateApexErrorLogs() {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Map<id, String> sObjectIdToErrorMessageMap = new Map<id, String>();
        sObjectIdToErrorMessageMap.put(oppty.id, 'Test');
        UTL_OWF.createApexErrorLogs('Opportunity', 'Error', sObjectIdToErrorMessageMap);
        
        Apex_Error_Log__c apexError = [Select Id from Apex_Error_Log__c limit 1];
        Test.stopTest();
        
        system.assertNotEquals(null, apexError.Id, 'Verifying CreateApexErrorLogs Functionality');
    }
    
    @isTest
    static void testCreateResourceCandidateMatchScoreWithTherapyArea() 
    {
        System.runAs(new User(Id = UserInfo.getUserId())) 
        {
            Test.startTest();
            
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
            insert skill;
            Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
            insert schedule;   
            List<Contact> contactList = [Select Id From Contact limit 10];
            contactList[0].Available_for_Triage_Flag__c = true;
            update contactList[0];
            List<pse__Resource_Request__c> resRequestList = [Select Id From pse__Resource_Request__c  where subgroup__c = 'TSL-Japan'];
            pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, contactList.get(0).Id, null);
            assignment.Assignment_Type__c = 'Days Off';
            assignment.pse__Status__c ='Days Off - Approved';
            insert assignment;
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
            insert skillCertRating;
            pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resRequestList.get(0).Id);
            insert resourceSkillRequest;    
            List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c FROM pse__Resource_Skill_Request__c limit 1000];
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreListReturn = UTL_OWF.calculateNWTimePercentage(resourceCandidateMatchScoreList);
            Test.stopTest();
            
            system.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Verifying CreateResourceCandidateMatchScoreWithTherapyArea Functionality');
            system.assertNotEquals(0, resourceCandidateMatchScoreListReturn.size(), 'Verifying CreateResourceCandidateMatchScoreWithTherapyArea Functionality');
        }
    }
    
    @isTest
    static void testIgnoreFTEThreshold() 
    {
        System.runAs(new User(Id = UserInfo.getUserId())) 
        {
            Test.startTest();
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
            insert skill;
            Bid_History__c agreement = [Select Id, Bid_History_Related_Opportunity__c From Bid_History__c limit 1];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
            insert schedule;
            List<Contact> contactList = [Select Id From Contact limit 10];
            contactList[0].Available_for_Triage_Flag__c = true;
            contactList[0].sub_group__c = 'Site Analytics';
            update contactList[0];
            pse__Grp__c grp = [select id from pse__Grp__c limit 1];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, agreement.Bid_History_Related_Opportunity__c, project.Id);
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.SubGroup__c = 'Site Analytics';
            insert resourceRequest;
            pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, contactList.get(0).Id, null);
            assignment.Assignment_Type__c = 'Days Off';
            insert assignment;
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
            insert skillCertRating;
            List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c FROM pse__Resource_Skill_Request__c limit 100];      
            pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resourceRequest.Id);
            insert resourceSkillRequest;    
            resourceSkillRequestList.add(resourceSkillRequest);
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
            List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreListReturn = UTL_OWF.calculateNWTimePercentage(resourceCandidateMatchScoreList);   
            Test.stopTest();   
            
            system.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Verifying IgnoreFTEThreshold Functionality');
            system.assertNotEquals(0, resourceCandidateMatchScoreListReturn.size(), 'Verifying IgnoreFTEThreshold Functionality');
        }
    }
    
    @isTest
    static void testcalculateDaysOffForRebid() 
    {
        System.runAs(new User(Id = UserInfo.getUserId())) 
        {
            Test.startTest();
            
            Contact cont = [Select Id From Contact Where LastName = 'TestContact'][0];
            Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
            Days_Off__c daysOffAssignment = new Days_Off__c();
            daysOffAssignment.First_Day_Off__c = system.today();
            daysOffAssignment.Last_Day_Off__c = daysOffAssignment.First_Day_Off__c.addDays(30);
            daysOffAssignment.Assignment_Type__c = 'Days Off';
            daysOffAssignment.Request_Type__c = 'Annual Leave/Vacation';
            daysOffAssignment.Employee__c = cont.Id;
            insert daysOffAssignment;
            Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
            pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, bidProject.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.SubGroup__c = 'TSL-Japan';
            resourceRequest.pse__Start_Date__c =  system.today().addDays(2);
            resourceRequest.pse__End_Date__c = resourceRequest.pse__Start_Date__c.addDays(7);
            insert resourceRequest;
            Map<Id,Id> rrIdtoContactIdMap = new Map<Id,Id>();
            rrIdtoContactIdMap.put(resourceRequest.Id,cont.Id);
            
            Map<Id,boolean> returendMap = UTL_OWF.calculateDaysOffForRebid(rrIdtoContactIdMap);
            Test.stopTest();
            
            system.assertEquals(false,returendMap.get(resourceRequest.Id), 'Verifying calculateDaysOffForRebid Functionality');
        }   
    }

    @isTest
    static void testcalculateDaysOffForClinicalBidRR() 
    {
        System.runAs(new User(Id = UserInfo.getUserId())) 
        {
           
            Contact cont = [Select Id From Contact Where LastName = 'TestContact'][0];
			cont.Available_for_Triage_Flag__c = true;
            cont.sub_group__c = 'TSL';
            update cont;
            Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
            Account acc = [Select id from Account limit 1];
            Days_Off__c daysOffAssignment = new Days_Off__c();
            daysOffAssignment.First_Day_Off__c = system.today().addDays(30);
            daysOffAssignment.Last_Day_Off__c = daysOffAssignment.First_Day_Off__c.addDays(30);
            daysOffAssignment.Assignment_Type__c = 'Days Off';
            daysOffAssignment.Request_Type__c = 'Annual Leave/Vacation';
            daysOffAssignment.Employee__c = cont.Id;
            insert daysOffAssignment;
            Bid_History__c earlyEngagementBid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID);
            earlyEngagementBid.Bid_Due_Date__c = system.today().addDays(5);
            insert earlyEngagementBid;
            Pse__Proj__c bidProject = [Select id from Pse__Proj__c where bid_History__c =: earlyEngagementBid.id];
            pse__Grp__c grp =[Select id from pse__Grp__c limit 1];
            Test.startTest();
            pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(earlyEngagementBid.Id, oppty.Id, bidProject.Id);
            resourceRequest1.pse__Group__c = grp.Id;
            resourceRequest1.SubGroup__c = 'TSL';
			resourceRequest1.LeadSupportFlag__c ='Lead';
            insert resourceRequest1;
            
            pse__Resource_Request__c resourceRequest =[Select id from pse__Resource_Request__c where Bid_History__c =: earlyEngagementBid.id];
            pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
            insert schedule;
            pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(earlyEngagementBid.id, bidProject.id, schedule.id, cont.id, resourceRequest.id);
            insert assignment;
            
            Bid_History__c agreement = [Select id from Bid_History__c where Bid_Number__c = 1 and recordTypeId =: CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID];
            agreement.Requested_Services__c = CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY;
            update agreement;
            
            List<pse__Assignment__c> assignment1 = [SELECT Id, Name,pse__Resource__c,pse__Resource_Request__c,pse__Resource_Request__r.subGroup__c from pse__Assignment__c where pse__Resource_Request__r.subGroup__c ='TSL' and pse__Resource_Request__r.bid_History__c =: agreement.id];
            Test.stopTest();
            system.assertEquals(assignment1[0].pse__Resource__c, cont.id, 'Verifying calculateDaysOffForClinicalBidRR Functionality');
        }   
    }


    @isTest
    static void testCreateRRForContractPostAwardBid(){
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Test.startTest();
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Is_this_a_Virtual_Trials_Study__c = 'Yes Fully Hybrid';
            oppty.Is_this_IQVIA_Biotech__c = 'No';
            update oppty;
            Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
            bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
            bidHistory.Requested_Agreement_Type__c = CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER;
            bidHistory.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;IQB Ongoing DM;IQB Project Management;IQB Site Contracts;RNPS';
            insert bidHistory;
            List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :bidHistory.Id and SubGroup__c = 'DSB-Clinical Post'];
            System.assertEquals(1, resReqsList.size(), 'Success');
        Test.stopTest();
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioECD()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Early Clinical Development';
        oppty.Potential_Regions__c = 'Global';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'ECD - Clinical Monitoring;ECD - Clinical Project Manager';
        agreement.Clinic_Site_included_in_proposal__c ='No';
        agreement.Master_CDA_for_External_sites_acceptable__c ='No';
        agreement.Status_of_IND__c='TBD';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'ECD-COE' limit 1];
        Test.stopTest();
        
        string expected = 'ECD-COE';
        system.assertEquals(expected, rr[0].SubGroup__c, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioGBO()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD' limit 1];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rr[0].SubGroup__c, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testProcessResRequestForInitialBids_ScenarioDSB()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Data Sciences';
        oppty.Potential_Regions__c = 'Global';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'CEVA;Medical Writing;Biostatistical;Data Management;Pharmacovigilance LifeCycle Safety';
        update agreement;
        
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rr = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%DSB%'];
        Test.stopTest();
        
        system.assert(rr.size() > 0, 'Verifying ProcessResRequestForInitialBids Functionality');
    }
    
    @isTest
    static void testValidateLIGForClinicalAgreement()
    {
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Commercial Solutions';
        oppty.Indication_List__c = null;
        oppty.Verbatim_Indication_Term__c = null;
        oppty.Drug_Product_Name__c = null;
        oppty.Phase_P__c = null;
        oppty.FSP__c = null;
        oppty.Global_project_unit__c = null;
        oppty.FPI_Date__c = null;
        oppty.Population_Age_Group__c = null;
        oppty.Is_this_IQVIA_Biotech__c = null;
        update oppty;
        Test.startTest();
        List<String> ligForClinicalBid = UTL_OWF.validateLIGForClinicalAgreement(oppty.Id,'Clinical Bid');
        List<String> ligForCSMS = UTL_OWF.validateLIGForClinicalAgreement(oppty.Id,'CSMS');
        Test.stopTest();
        
        system.assertNotEquals(null, ligForClinicalBid, 'Verifying ValidateLIGForClinicalAgreement Functionality');
    }
    
    @isTest
    static void testredirectUserOnRTSelection()
    {
        Test.startTest();
        String redirect = UTL_OWF.redirectUserOnRTSelection(null);
        Test.stopTest();
        
        system.assert(redirect.length() > 0, 'Verifying redirectUserOnRTSelection Functionality');
    }
    
    @isTest
    static void testfindNoOfDays_exclude_weekend()
    {
        Date startdate = system.today().addDays(1);
        Date Enddate = system.today().addDays(10);
        Integer Numberofholidays = 2;
        Test.startTest();
        Integer noofdays = UTL_OWF.findNoOfDays_exclude_weekend(startdate, Enddate, Numberofholidays);
        Test.stopTest();  
        
        system.assertNotEquals(0, noofdays, 'Verifying findNoOfDays_exclude_weekend Functionality');
    }
    
    @isTest
    static void testvalidateResourceGroup()
    {
        Contact c = [Select Id from Contact limit 1];
        Test.startTest();
        Boolean groupBoolean = UTL_OWF.validateResourceGroup(c.Id);
        Test.stopTest();
        
        system.assertEquals(False, groupBoolean, 'Verifying validateResourceGroup Functionality');        
    }
    
    @isTest
    static void testECD()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Early Clinical Development';
        oppty.Potential_Regions__c = 'USA/Canada';
        oppty.Potential_Regions__c = 'Europe/Middle East/Africa EMEA';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'ECD - Clinical Monitoring;ECD - Clinical Project Manager';
        agreement.Clinic_Site_included_in_proposal__c ='No';
        agreement.Master_CDA_for_External_sites_acceptable__c ='No';
        agreement.Status_of_IND__c='TBD';
        agreement.Triage_Level__c = 'Level A Experience or Staffing';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> resourceRequestList1 = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%ECD%'];
        Test.stopTest();
        
        system.assert(resourceRequestList1.size() > 0, 'Verifying ECD Functionality');  
    }
    
    @isTest
    static void testGBOBidGridforclinical()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';        
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforclinical Functionality');
    }
    
    @isTest
    static void testGBOBidGridforOutcome()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Outcome';
        oppty.QI_Invited_to_Present__c = 'Yes';  
        oppty.Presentation_Date_Status__c='Estimated';
        oppty.Presentation_Country__c='Afghanistan';
        oppty.BDM_Resources__c='Data Strategy Lead';
        oppty.Is_there_a_regulatory_purpose__c = 'test';
        oppty.Proposal_Due_Date__c = System.today();
        
        update oppty;        
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforOutcome Functionality');
    }
    
    @isTest
    static void testGBOBidGridforNovella()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';        
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforNovella Functionality');
    }
    
    @isTest
    static void testGBOBidGridforDataManagement(){
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Data Sciences';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforDataManagement Functionality');
    }    
    
    @isTest
    static void testGBOBidGridforLifecycleSafety(){
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Safety & Med Info';
        update oppty;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforLifecycleSafety Functionality');
    }
    
    @isTest
    static void testGBOBidGridforEarlyClinicalDevelopment()
    {
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Early Clinical Development';
        update oppty;
        Bid_HIstory__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        agreement.Clinic_Site_included_in_proposal__c = 'No';
        agreement.Master_CDA_for_External_sites_acceptable__c ='No';
        agreement.Status_of_IND__c='TBD';
        update agreement;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Bid Grid'];
        Test.stopTest();
        
        String expected = 'GBO-Bid Grid';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOBidGridforEarlyClinicalDevelopment Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforOutcome()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Outcome'; 
        oppty.QI_Invited_to_Present__c = 'Yes';  
        oppty.Presentation_Date_Status__c='Estimated';
        oppty.Presentation_Country__c='Afghanistan';
        oppty.BDM_Resources__c='Data Strategy Lead';
        oppty.Is_there_a_regulatory_purpose__c = 'test';
        oppty.Proposal_Due_Date__c = System.today();
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforOutcome Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforNovella()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';        
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforNovella Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforDataManagement()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Data Sciences';        
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforDataManagement Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforBiostatisticalMedicalWriting()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Data Sciences';        
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Targeted_Countries__c = 'JP';
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforBiostatisticalMedicalWriting Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforLifecycleSafety(){
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Safety & Med Info';        
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforLifecycleSafety Functionality');
    }
    
    @isTest
    static void testGBOLeadPdforEarlyClinicalDevelopment()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Early Clinical Development';        
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Is_there_a_Client_Bid_Grid__c = 'Yes';
        agreement1.Clinic_Site_included_in_proposal__c = 'No';
        agreement1.Master_CDA_for_External_sites_acceptable__c ='No';
        agreement1.Status_of_IND__c='TBD';
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'GBO-Lead PD'];
        Test.stopTest();
        
        String expected = 'GBO-Lead PD';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying GBOLeadPdforEarlyClinicalDevelopment Functionality');
    }
    
    @isTest
    static void testCAGTCOE2()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.InterventionType__c = 'Cell and Gene Therapy';
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Potential_Regions__c = 'Global';
        oppty.Potential_Regions__c = 'USA/Canada';
        oppty.Potential_Regions__c = 'Europe/Middle East/Africa EMEA';
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Requested_Services__c = CON_OWF.REQUESTED_INTERNAL_SERVICES_IQB_PROJECT_MANAGEMENT;
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%CAGT%' limit 1];
        Test.stopTest();
        
        system.assert(rrList.size()>0, 'Verifying CAGTCOE Functionality');
        
    }
    
    @isTest
    static void testCPADIPA()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        pse__Skill__c skill = UTL_OWF_TestData.createSkills(CON_OWF.SKILL_NAME_STRATEGIC_ANALYTICS, CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY);
        insert skill;
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Is_this_IQVIA_Biotech__c = 'No';
        oppty.Potential_Regions__c = 'Global';
        oppty.Potential_Regions__c = 'USA/Canada';
        oppty.Potential_Regions__c = 'Europe/Middle East/Africa EMEA';
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement1.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        agreement1.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement1.Opportunity_Type__c = 'Full service RFP';
        agreement1.RFP_Ranking__c = '4';
        agreement1.Budget_Deliverable__c = 'Full Budget';
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%TAL%' limit 1];
        Test.stopTest();
        system.assert(rrList.size()==1, 'Verifying CPADIPA Functionality');
    }
    
    @isTest
    static void testBiosimilarCOEforclinical()
    {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.InterventionType__c = 'Biosimilar';
        update oppty;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c= 'Biosimilar-COE'];
        Test.stopTest();
        
        String expected = 'Biosimilar-COE';
        system.assertEquals(expected, rrList[0].SubGroup__c, 'Verifying BiosimilarCOEforclinical Functionality');
    }
    
    /*@isTest
    static void testMedicalAnalytics()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%Medical Analytics%' limit 1];
        Test.stopTest();
        system.assert(rrList.size()>0, 'Verifying MedicalAnalytics Functionality');
    }*/
    
    
    @isTest
    static void testCTSLead()
    {
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Test.startTest();
        Opportunity oppty = [Select Id, Potential_Regions__c From Opportunity where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        update oppty;
        Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement1.Requested_Services__c = 'CTS';
        agreement1.Bid_Due_Date__c = Date.today().addDays(5);
        agreement1.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
        agreement1.RFP_Ranking__c = '3';
        agreement1.Budget_Deliverable__c = 'Full Budget';
        agreement1.Additional_Services_Requested__c	 = 'Drug Supply and Distribution';
        insert agreement1;
        Set<Id> sObjectIdSet = new Set<Id>{oppty.Id};
            String agrCondition = 'Bid_History_Related_Opportunity__c != NULL And Bid_History_Related_Opportunity__c IN :sObjectIdSet ' +
            ' And RecordTypeId = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        UTL_OWF.processResRequestForInitialBids(sObjectIdSet, agrCondition, null, null);
        
        List<pse__Resource_Request__c> rrList = [SELECT Id, Name, SubGroup__c from pse__Resource_Request__c where SubGroup__c like '%CTS-Lead%' limit 1];
        Test.stopTest();
        system.assert(rrList.size()>0, 'Verifying CTSLead Functionality');
    }
    
    @isTest
    static void testSendEmailThroughWorkflow() {
        
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        List<User> testUser1 = UTL_TestData.createUser('System Administrator', 1);
        testUser1[0].IsActive = true;
        insert testUser1[0];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Scientific_Review__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Protocol_Number__c = '1234';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Bid_Type__c = 'Mock';
        bidHistory.Study_Phase__c = 'Study Phase';
        bidHistory.Enrollement_Months__c = 3;
        bidHistory.Patient_Duration_Months__c = 4; 
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Requested_Services__c = 'CEVA';
        bidHistory.Pertinent_Details_Specific_Rebid_Request__c = 'ABCD'; 
        bidHistory.Strategic_Pricing_Lead__c = testUser1[0].Id;
        bidHistory.Submit_to_Contracts__c = true;
        bidHistory.Bid_Owner_Deliverable__c = 'Other';
        bidHistory.Bid_Complexity__c = 'Low';
        insert bidHistory;
        
        Test.stopTest();
        
        List<UTL_OWF.workflowEmailRecordWrapper> messageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
        UTL_OWF.workflowEmailRecordWrapper message = new UTL_OWF.workflowEmailRecordWrapper();
        message.toEmails = new List<String>{'xyz@abc.com'};
            message.ccEmails = new List<String>{'abc@abc.com'};
                message.staticContent = '<html><body>Test Email</body></html>';
        message.subject = 'Test Mail';
        message.whatId = bidHistory.Id;
        messageList.add(message);

        UTL_OWF.sendEmailByWorkflowEmailRecord(messageList);

        List<Workflow_Email_Record__c> records = [Select Id from Workflow_Email_Record__c];
        System.assertNotEquals(records.size(), 0,'Success'); 
    }
    @isTest
    static void testUpdateContractPostAwardbidFromOtherObject() {
        
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
        Test.stopTest();
        
        List<BidHistoryWrapper> wrapperList = new List<BidHistoryWrapper>();
        BidHistoryWrapper bid = new BidHistoryWrapper();
        bid.SObjectName = 'Quote';
        bid.bidHistoryId = bidHistory.id;
        bid.plannedExecutionDate = System.today();
        wrapperList.add(bid);
        UTL_OWF.updateContractPostAwardbidFromOtherObject(wrapperList);
        
        Bid_History__c bid1 = [Select id, Bid_Due_Date__c from Bid_History__c Where id =: bidHistory.id];
        System.assertEquals(System.today(), bid1.Bid_Due_Date__c, 'Success'); 
    }
    
    @isTest
    static void testsetWorkflowParameter(){
        Test.startTest();
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        List<User> testUser1 = UTL_TestData.createUser('System Administrator', 1);
        testUser1[0].IsActive = true;
        insert testUser1[0];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Scientific_Review__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Protocol_Number__c = '1234';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Bid_Type__c = 'Mock';
        bidHistory.Study_Phase__c = 'Study Phase';
        bidHistory.Enrollement_Months__c = 3;
        bidHistory.Patient_Duration_Months__c = 4; 
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Requested_Services__c = 'CEVA';
        bidHistory.Pertinent_Details_Specific_Rebid_Request__c = 'ABCD'; 
        bidHistory.Strategic_Pricing_Lead__c = testUser1[0].Id;
        bidHistory.Submit_to_Contracts__c = true;
        bidHistory.Bid_Owner_Deliverable__c = 'Other';
        bidHistory.Bid_Complexity__c = 'Low';
        insert bidHistory;
        UTL_OWF.workflowEmailRecordWrapper message = new UTL_OWF.workflowEmailRecordWrapper();
        Workflow_Email_Record__c record = new Workflow_Email_Record__c();
        
        message.whatId = bidHistory.Id;
        message.toEmails = new List<String>{'xyz@abc.com'};
		message.ccEmails = new List<String>{'abc@abc.com'};
            message.toUserIds = new List<String>{UserInfo.getUserId()};
                message.ccUserIds = new List<String>{UserInfo.getUserId()};
		UTL_OWF.setWorkflowParameter(record, message);
        Test.stopTest();
        
        System.assertEquals(record.To_Email_1__c, 'xyz@abc.com','Success');
        System.assertEquals(record.To_Email_2__c, 'abc@abc.com','Success');
        System.assertEquals(record.To_User_1__c, UserInfo.getUserId(),'Success');
        System.assertEquals(record.To_User_2__c, UserInfo.getUserId(),'Success');
        System.assertEquals(record.Related_To_Object_Id__c, bidHistory.Id,'Success');
        System.assertEquals(record.Related_To_Object_Api__c, 'Bid_History__c','Success');
        System.assertEquals(record.Module_Name__c, 'OWF','Success');
     }
    
     @isTest
     static void testIsValidEmailId(){
        System.assertEquals(UTL_OWF.isValidEmailId('xyz@abc.com'), true,'Success');
        System.assertEquals(UTL_OWF.isValidEmailId('xy___33z@abc.com'), true,'Success'); 
        System.assertEquals(UTL_OWF.isValidEmailId('@abc.com'), false,'Success'); 
        System.assertEquals(UTL_OWF.isValidEmailId('abc.com'), false,'Success'); 
    }
    
     @isTest
     static void testCreateRRForCSSBid(){
       Account acc = [Select id from Account limit 1];
       Opportunity opp = [Select id,Line_of_Business__c from Opportunity limit 1];
       opp.Line_of_Business__c = CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY;
       update opp;
         test.StartTest();
       Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 1;
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.Connected_Devices__c = True;
        bidHistory.Bid_Due_Date__c = System.today().addDays(30);
        bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory;
         test.stopTest();
        List<pse__Resource_Request__c> rrList = [Select id from pse__Resource_Request__c where Bid_History__c =: bidHistory.id];
        System.assertNotEquals(0,rrList.size(),'RRs created');
    }
    
    @isTest
    static void testGetLatestQuote(){
        Account acc = [Select id from Account limit 1];
       	Opportunity opp = [Select id,Line_of_Business__c from Opportunity limit 1];
        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        insert quote;
        test.StartTest();
        Map<Id, Quote__c> quoteMap = UTL_OWF.getLastAcceptedQuote(new Set<Id>{opp.Id});
        test.stopTest();
        System.assertNotEquals(quoteMap.size(),0,'Last Accepted Quote');
        
    }
    @isTest
    static void testValidateLQOppForBidHistory(){
        Account acc = [Select id from Account limit 1];
       	Opportunity opp = [Select id,Line_of_Business__c from Opportunity limit 1];
        test.StartTest();
        List<String> validationMsg1 = UTL_OWF.validateLQOppForBidHistory(opp.Id,CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        System.assertNotEquals(0,validationMsg1.size(),'Validation message is returned');
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.Identified_Business__c = null;
        opp.Q2_Budget_Tool__c = 'Q2 Bio';
        update opp;
        List<String> validationMsg2 = UTL_OWF.validateLQOppForBidHistory(opp.Id,CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        System.assertNotEquals(0,validationMsg2.size(),'Validation message is returned');
        test.stopTest();
    }

    @isTest
    static void testProcessResRequestForInitialBids_TSL(){
      Account acc = [Select id from Account limit 1];
      pse__Grp__c grp = [Select Id From pse__Grp__c limit 1];
      Opportunity opp = [Select id,Line_of_Business__c from Opportunity limit 1];
      opp.Line_of_Business__c = CON_OWF.LINE_OF_BUSINESS_CLINICAL_TECHNOLOGY;
      update opp;
       test.StartTest();
       Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
       bidHistory.Bid_Number__c = 1;
       bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
       bidHistory.Connected_Devices__c = True;
       bidHistory.Bid_Due_Date__c = System.today().addDays(30);
       bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
       bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
       bidHistory.Study_Start_Date__c =  system.today();
       bidHistory.Study_End_Date__c = system.today().addMonths(1);
       bidHistory.RFP_Ranking__c = '1';
       bidHistory.Bid_Number__c = 1;
       insert bidHistory;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.Is_Bid_Defense__c = true;
        resourceRequest.pse__Status__c = 'Assigned';
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__Status__c = 'Assigned';
        insert resourceRequest;
        test.StopTest();

        List<pse__Resource_Request__c> rrList = [Select id from pse__Resource_Request__c where Bid_History__c =: bidHistory.id];
        System.assertNotEquals(0,rrList.size(),'RRs created');
        
    }
    @isTest
    public static void testGetAnalystStartDateforAgreement(){
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Is_this_a_Virtual_Trials_Study__c = 'Yes Fully Hybrid';
        oppty.Is_this_IQVIA_Biotech__c = 'No';
        update oppty;
        pse__Schedule__c schedule1 = UTL_OWF_TestData.createSchedule();
        insert schedule1;
        Contact cont = [select id,sub_Group__c from Contact limit 1];
        cont.sub_Group__c ='GBO-Lead PD';
        update cont;
        Test.startTest();
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
        bidHistory.Requested_Agreement_Type__c = CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER;
        bidHistory.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;IQB Ongoing DM;IQB Project Management;IQB Site Contracts;RNPS';
        insert bidHistory;
        pse__Proj__c bidProject = [select id from pse__Proj__c where bid_History__c =: bidHistory.id];
        pse__grp__c grp = [Select id from pse__grp__c limit 1];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, oppty.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'GBO-Lead PD';
        insert resourceRequest;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(bidHistory.id, bidProject.id, schedule1.id, cont.id, resourceRequest.id);
        insert assignment;
        assignment.pse__Status__c = 'Accepted';
        update assignment;
        Map<Id,Date> bidIdToStartDateOFRR = UTL_OWF.getAnalystStartDateforAgreement(new Set<Id>{bidHistory.id});
        Test.stopTest();
        System.assertNotEquals(0,bidIdToStartDateOFRR.size(),'GetAnalystStartDateforAgreement created');
    }
}
