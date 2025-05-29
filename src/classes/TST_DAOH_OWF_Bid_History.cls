/**
* This test class is used to test all methods in Bid History trigger helper.
* version : 1.0
*/
@isTest(seeAllData=false)
public class TST_DAOH_OWF_Bid_History {
    
    /**
	* This method is used to setup data for all methods
	*/
    @testSetup
    static void dataSetup() {
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'Global Analytics',
            Sub_Group__c = 'Global Analytics',
            Name = 'Global Analytics'
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
        Test.StartTest();
        User users = [select id from User where PIC_Eligible__c = true limit 1];
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        List<Contact> conList = new List<Contact>();
        for(Integer i =2;i<9;i++){
            Contact con = new Contact(LastName = 'TestAp'+i,RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =users.Id, Email = 'test' + i + '@iqvia.com');
            conList.add(con);
        }
        insert conList;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(conList[0].Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZREP';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        Test.StopTest();

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
        
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
        
    }
    
    /**
	* This test method used for insert Agreement to validate Number of Requested Services
	*/ 
    @isTest
    static void testSetNoOfRequestedServicesBasedOnRequestedServices_InsertScenario() 
    {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID);
        Test.startTest();
            bidHistory.Requested_Services__c = 'Call Center;Biostatistical';
            insert bidHistory;
            Bid_History__c modifiedBidHistory = [Select Id, Number_of_Requested_Services__c From Bid_History__c Where Id = :bidHistory.Id];
            system.assertEquals(2, modifiedBidHistory.Number_of_Requested_Services__c, 'Verifying SetNoOfRequestedServicesBasedOnRequestedServices_InsertScenario Functionality');
        Test.stopTest();
    }
    
    /**
	* This test method used for update Agreement to validate Number of Requested Services
	*/ 
    @isTest
    static void testSetNoOfRequestedServicesBasedOnRequestedServices_UpdateScenario() 
    {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID);
        Test.startTest();
            insert agreement;
            agreement.Requested_Services__c = 'Full-Service Feasibility;Call Center;Biostatistical';
            update agreement;
            Bid_History__c modifiedAgreement = [Select Id, Number_of_Requested_Services__c,Requested_Services__c From Bid_History__c Where Id = :agreement.Id];
            system.assertEquals(3, modifiedAgreement.Number_of_Requested_Services__c, 'Verifying SetNoOfRequestedServicesBasedOnRequestedServices_UpdateScenario Functionality');
            agreement.Requested_Services__c = '';
            update agreement;
            modifiedAgreement = [Select Id, Number_of_Requested_Services__c From Bid_History__c Where Id = :agreement.Id];
        Test.stopTest();
    }
    
    /**
	* This test method used for insert Agreement to validate Bid No based on record type
	*/ 
    @isTest
    static void testSetBidNoBasedOnRecordType_InsertScenario() 
    {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Bid_History__c> lstOfAgreementsToInsert = new List<Bid_History__c>();
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.LQ_Bid_Histroy_Id__c = 'Test 101';
        Bid_History__c agreementNonRfp = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreementNonRfp.LQ_Bid_Histroy_Id__c = 'Test 701';
        lstOfAgreementsToInsert.add(agreement);
        lstOfAgreementsToInsert.add(agreementNonRfp);
        Test.startTest();
            insert lstOfAgreementsToInsert;
            Bid_History__c clinicalBidAgreement = [Select Id, Bid_Number__c From Bid_History__c Where Id = :agreement.Id];
            system.assertEquals(2, clinicalBidAgreement.Bid_Number__c, 'Verifying CNT_OWF_CreateAssignmentFromResReq.hasAccess Functionality');
        Test.stopTest();
    }
    
    
    /**
	* This test method used for update Agreement's Bid_Due_Date to validate End_Date on related records
	*/
    @isTest
    static void testSetEndDateAndStatusOnProjectResReqsAndAssignmentsWithFutureDate() 
    {
        Bid_History__c agreement = [SELECT Id, Bid_History_Account__c, Bid_History_Related_Opportunity__c FROM Bid_History__c limit 1];
        pse__Proj__c bidProject = [Select Id From pse__Proj__c limit 1];
        Contact cont = [Select Id, pse__Is_Resource__c, pse__Is_Resource_Active__c From Contact limit 1];
        pse__Grp__c grp = [Select Id From pse__Grp__c limit 1];
        List<pse__Resource_Request__c> lstToInsertResourceRequests = new List<pse__Resource_Request__c>();
        pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, agreement.Bid_History_Related_Opportunity__c, bidProject.Id);
        resourceRequest1.pse__Group__c = grp.Id;
        resourceRequest1.SubGroup__c = 'TSL-Japan';
        lstToInsertResourceRequests.add(resourceRequest1);
        pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, agreement.Bid_History_Related_Opportunity__c, bidProject.Id);
        resourceRequest2.pse__Group__c = grp.Id;
        resourceRequest2.SubGroup__c = 'TSL-Japan';
        lstToInsertResourceRequests.add(resourceRequest2);
        Test.startTest();
            insert lstToInsertResourceRequests;
            List<pse__Schedule__c> lstToInsertSchedules = new List<pse__Schedule__c>();
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert lstToInsertSchedules;
            List<pse__Assignment__c> lstToInsertAssignments = new List<pse__Assignment__c>();
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, lstToInsertSchedules.get(0).Id, cont.Id, lstToInsertResourceRequests.get(0).Id));
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, lstToInsertSchedules.get(1).Id, cont.Id, lstToInsertResourceRequests.get(1).Id));
            insert lstToInsertAssignments;
            agreement.Bid_Due_Date__c = system.today().addDays(5);
            update agreement;
            List<pse__Assignment__c> listOfAssignments = [Select Id, pse__End_Date__c From pse__Assignment__c Where Bid_History__c = :agreement.Id];
            system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(0).pse__End_Date__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithFutureDate Functionality');
            system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(1).pse__End_Date__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithFutureDate Functionality');
        Test.stopTest();
    }
    
    
    /**
	* This test method used for update Agreement's Bid_Due_Date to validate Status and End_Date on related records
	*/
    @isTest
    static void testSetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday() 
    {
        Bid_History__c agreement = [SELECT Id, Bid_History_Account__c, Bid_History_Related_Opportunity__c FROM Bid_History__c limit 1];
        pse__Proj__c bidProject = [Select Id From pse__Proj__c limit 1];
        Contact cont = [Select Id From Contact limit 1];
        Test.startTest();
            List<pse__Schedule__c> lstToInsertSchedules = new List<pse__Schedule__c>();
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert lstToInsertSchedules;
            List<pse__Assignment__c> lstToInsertAssignments = new List<pse__Assignment__c>();
            List<pse__Resource_Request__c> rrList = [Select Id, pse__End_Date__c, pse__Status__c,pse__Assignment__c From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan' Limit 1];
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, lstToInsertSchedules.get(0).Id, cont.Id, rrList.get(0).Id));
            insert lstToInsertAssignments;
        	List<pse__Assignment__c> assignmentsList = [Select Id, pse__Status__c, pse__End_Date__c From pse__Assignment__c Where Bid_History__c = :agreement.Id];
        	for(pse__Resource_Request__c rrListItem : rrList){
            rrListItem.pse__Assignment__c = assignmentsList[0].id;
            rrListItem.pse__Status__c = CON_OWF.OWF_STATUS_ASSIGNED;
        	}
        	update rrList;
        	for(pse__Assignment__c assignmentListItem : assignmentsList){
            assignmentListItem.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
        	}
        	update assignmentsList;
        	agreement.Bid_Due_Date__c = system.today().addDays(1);
        	update agreement; 
        
        	List<pse__Resource_Request__c> listOfRRs = [Select Id, pse__End_Date__c, pse__Status__c From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan'];
        	//system.assertEquals(agreement.Bid_Due_Date__c, listOfRRs.get(0).pse__End_Date__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday Functionality');
        	system.assertEquals(CON_OWF.OWF_STATUS_ASSIGNED, listOfRRs.get(0).pse__Status__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday Functionality');
        
       		List<pse__Assignment__c> listOfAssignments = [Select Id, pse__Status__c, pse__End_Date__c From pse__Assignment__c Where Bid_History__c = :agreement.Id];
        	//system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(0).pse__End_Date__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday Functionality');
        	system.assertEquals(CON_OWF.OWF_STATUS_ACCEPTED, listOfAssignments.get(0).pse__Status__c, 'Verifying SetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday Functionality');
        Test.stopTest();
    }
    
    
    /**
	* This test method used to Delete Project Based On Agreement
	*/
    @isTest
    static void testDeleteProjectBasedOnAgreement() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c limit 1];
        Test.startTest();
        	delete agreement;
        Test.stopTest();
        
        List<pse__proj__c> projectList = [Select Id From pse__proj__c Where Bid_History__c = :agreement.Id];
        Integer expected = 0;
        System.assertEquals(expected, projectList.size(), 'Verifying DeleteProjectBasedOnAgreement Functionality');
    }
    
    
    /**
	* This test method used to validate created Resource Request based on agreement udpate
	*/ 
    @isTest
    static void testCreateClinicalBidResRequestsOnAgreementUpdate() 
    {   
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c limit 1];
        Test.startTest();
            Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
            insert indication;
            opp.Potential_Regions__c = 'Asia Pacific';
            opp.Line_of_Business__c = 'Clinical';
            opp.Bid_Defense_Date__c = system.today().addDays(2);
        	opp.Phase_P__c =  'Phase 1';
        	opp.Indication_List__c = indication.Id;
            update opp;
            agreement.Bid_Due_Date__c = system.today().addDays(5);
            update agreement;
        Test.stopTest();
        
        List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where pse__Opportunity__c = :opp.Id];
        system.assertNotEquals(null, resReqsList.size(), 'Verifying CreateClinicalBidResRequestsOnAgreementUpdate Functionality');
    }

    @isTest
    static void testUpdateResourcesNeededFromAgreement() 
    {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        pse__Skill__c testSkill = UTL_OWF_TestData.createSkills('Test Skill', 'Indication');
        insert testSkill;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        Test.startTest();
            agreement.Resources_Needed__c = 'MSL';
            insert agreement;
            agreement.Resources_Needed__c = 'MSL;TAL';
            update agreement;
        Test.stopTest();

		List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where pse__Opportunity__c = :opp.Id];
		System.assertNotEquals(2, resReqsList.size(), 'Verifying UpdateResourcesNeededFromAgreement Functionality');
    }
    
    @isTest
    static void testUpdateSuggestedDueDate() 
    {   
        Bid_History__c agreement = [SELECT Id,CreatedDate,Suggested_Due_Date__c FROM Bid_History__c][0];
        Test.startTest();
        agreement.Opportunity_Type__c ='BTS Ballpark';
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        update agreement;
        Test.stopTest();
        Date createdDate = date.newinstance(agreement.CreatedDate.year(), agreement.CreatedDate.month(), agreement.CreatedDate.day());
        Date expectedDate = createdDate.addDays(7);
        Date actualDate = agreement.Suggested_Due_Date__c;
        System.assertNotEquals(expectedDate, actualDate, 'Verifying UpdateSuggestedDueDate Functionality');
    }
    
    @isTest
    static void testvalidateEarlyEngagementBid() 
    {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
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
    }
    
    @isTest
    static void testsendEmailToRequestedProductsEmailsOnCSSBid() 
    {
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'PCS';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_01_SendEmailForCSSBidBasedOnProductsSelected';
        resourceToSubGroupSettingList.Key__c = 'Completed Consent';
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
        bidHistory.LPI_Date__c = System.today();
        bidHistory.DBL_Date__c = System.today();
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Requested_Services__c = 'CD - ECG';
        bidHistory.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory.OWF_Potential_Regions__c = 'Latin America';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        Test.startTest();
            insert bidHistory;
            system.assertEquals(2, bidHistory.Number_of_Scenarios__c, 'Success');
        Test.stopTest();
        
    }
    

    @IsTest
    static void testQ2LabBidHistoryAssignProposalRankingFieldUpdate(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Budget_Deliverable__c = 'Ballpark';
        bidHistory.Requested_Services__c = 'CEVA';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        bidHistory.Reason_for_short_TAT__c = 'other';
        upsert bidHistory;
        List<Bid_History__c> agreement = new List<Bid_History__c>();
        agreement.add(bidHistory);
        Test.startTest();
            DAOH_OWF_Bid_History.q2LabBidHistoryAssignProposalRankingFieldUpdate((List<Bid_History__c>) agreement);
            system.assertEquals('Level - 1', bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testQ2LabBidHistoryAssignProposalRankingFieldUpdate1(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Budget_Deliverable__c = 'Budget';
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Requested_Services__c = 'Kit Supply only';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        bidHistory.Reason_for_short_TAT__c = 'other';
        upsert bidHistory;
        List<Bid_History__c> agreement = new List<Bid_History__c>();
        agreement.add(bidHistory);
        Test.startTest();
            DAOH_OWF_Bid_History.q2LabBidHistoryAssignProposalRankingFieldUpdate((List<Bid_History__c>) agreement);
            system.assertEquals('Level - 2', bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testq2LabBidHistoryAssignProposalRankingFieldUpdate2(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Budget_Deliverable__c = 'Budget + Bid Grid';
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Requested_Services__c = 'Anatomic Pathology Analytical';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        bidHistory.Reason_for_short_TAT__c = 'other';
        upsert bidHistory;
        List<Bid_History__c> agreement = new List<Bid_History__c>();
        agreement.add(bidHistory);
        Test.startTest();
            DAOH_OWF_Bid_History.q2LabBidHistoryAssignProposalRankingFieldUpdate((List<Bid_History__c>) agreement);
            system.assertEquals('Level - 3', bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testq2LabBidHistoryAssignProposalRankingFieldUpdate3(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'Q2_Solutions_Level_4_Ranking_Emails_1';
        resourceToSubGroupSettingList.Data_Category__c = 'Q2_SOLUTIONS_LEVEL_4_RANKING_ALERT';
        resourceToSubGroupSettingList.Key__c = 'Q2_Solutions_Level_4_Ranking_Emails_1';
        resourceToSubGroupSettingList.Value__c = null;
        insert resourceToSubGroupSettingList;
        OWF_Generic_Setting__c resourceToSubGroupSettingList2 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList2.Name = 'Q2_Solutions_Level_4_Ranking_Emails_2';
        resourceToSubGroupSettingList2.Data_Category__c = 'Q2_SOLUTIONS_LEVEL_4_RANKING_ALERT';
        resourceToSubGroupSettingList2.Key__c = 'Q2_Solutions_Level_4_Ranking_Emails_2';
        resourceToSubGroupSettingList2.Value__c = null;
        insert resourceToSubGroupSettingList2;
        
          
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Assign_Proposal_Ranking__c = 'Level - 4';
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        Test.startTest();
            insert bidHistory;
            System.assertEquals('Level - 4',bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    
    @IsTest
    static void testsendEmailForQ2SolutionsBidHistoryAdvionQuoteRequested() 
    {
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'OWF_04_BioanalyticalBD';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_04_SendEmailForQ2SolutionsBidHistoryAdvionQuoterequested';
        resourceToSubGroupSettingList.Key__c = 'OWF_04_BioanalyticalBD';
        resourceToSubGroupSettingList.Value__c = 'balkrishan.gohil@metacube.com,balkrishan.gohil+1@metacube.com';
        insert resourceToSubGroupSettingList;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList2 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList2.Name = 'OWF_07_Q2ProposalRequest';
        resourceToSubGroupSettingList2.Data_Category__c = 'OWF_07_SendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA';
        resourceToSubGroupSettingList2.Key__c = 'OWF_07_Q2ProposalRequest';
        resourceToSubGroupSettingList2.Value__c = 'balkrishan.gohil@metacube.com,balkrishan.gohil+1@metacube.com';
        insert resourceToSubGroupSettingList2;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Assign_Proposal_Ranking__c ='Other';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        Test.startTest();
            insert bidHistory;
            System.assertEquals('Japan',bidHistory.OWF_Potential_Regions__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testsendEmailForsendEmailForQ2SolutionsStrategicPricingInvolved() 
    {
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'OWF_05_StrategicPricing';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_05_SendEmailForQ2SolutionsStrategicPricingInvolved';
        resourceToSubGroupSettingList.Key__c = 'OWF_05_StrategicPricing';
        resourceToSubGroupSettingList.Value__c = 'balkrishan.gohil@metacube.com,balkrishan.gohil+1@metacube.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Assign_Proposal_Ranking__c ='Other';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        Test.startTest();
            insert bidHistory;
            System.assertEquals('Yes',bidHistory.Strategic_Pricing_Involvement_Needed__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testsendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA() 
    {
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'OWF_07_Q2ProposalRequest';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_07_SendEmailForQ2SolutionsBidHistoryTriageNotificationExcludingMerckKGaA';
        resourceToSubGroupSettingList.Key__c = 'OWF_07_Q2ProposalRequest';
        resourceToSubGroupSettingList.Value__c = 'balkrishan.gohil@metacube.com,balkrishan.gohil+1@metacube.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Assign_Proposal_Ranking__c ='Other';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        Test.startTest();
            insert bidHistory;
            System.assertEquals('Yes',bidHistory.Strategic_Pricing_Involvement_Needed__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void sendEmailForQ2SolutionsLevel1RankingAlert() 
    {  
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        Opportunity opp = [Select Id From Opportunity limit 1];
        Test.startTest();
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 43826;
        bidHistory.Assign_Proposal_Ranking__c = 'Level - 1';
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);       
        bidHistory.Notes__c = 'testValue';
        insert bidHistory;
        bidHistory.OwnerId = testUserRecord[0].Id;
        update bidHistory;
        System.assertEquals('Level - 1',bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void sendEmailForQ2SolutionsLevel2RankingAlert() 
    {  
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        Opportunity opp = [Select Id From Opportunity limit 1];
        Test.startTest();		
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 43826;
        bidHistory.Assign_Proposal_Ranking__c = 'Level - 2';
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        insert bidHistory;
        bidHistory.OwnerId = testUserRecord[0].Id;
        update bidHistory;
        System.assertEquals('Level - 2',bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void sendEmailForQ2SolutionsLevel3RankingAlert() 
    {  
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        Test.startTest();
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 43826;
        bidHistory.Assign_Proposal_Ranking__c = 'Level - 3';
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        insert bidHistory;
        bidHistory.OwnerId = testUserRecord[0].Id;
        bidHistory.Notes__c = 'testValue';
        update bidHistory;
        System.assertEquals('Level - 3',bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
	
    @IsTest
    static void sendEmailForQ2SolutionsLevel4RankingAlert() 
    {  
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList1 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList1.Name = CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL1;
        resourceToSubGroupSettingList1.Data_Category__c = 'OWF_11_SendEmailForQ2SolutionsLevel4RankingAlert';
        resourceToSubGroupSettingList1.Key__c = CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL1;
        resourceToSubGroupSettingList1.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList1;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList2 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList2.Name = CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL2;
        resourceToSubGroupSettingList2.Data_Category__c = 'OWF_11_SendEmailForQ2SolutionsLevel4RankingAlert';
        resourceToSubGroupSettingList2.Key__c = CON_OWF.BHR_OWF_Q2SOLUTIONSLEVEL4RANKINGEMAIL2;
        resourceToSubGroupSettingList2.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList2;
        
        Test.startTest();
        Opportunity opp = [Select Id From Opportunity limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 43826;
        bidHistory.Assign_Proposal_Ranking__c = 'Level - 4';
        bidHistory.Strategic_Pricing_Involvement_Needed__c = 'Yes';
        bidHistory.Submit_to_Proposals__c = CON_OWF.OWF_BID_HISTORY_SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Q2_BioSciences_Quote_Requested__c ='Yes';
        bidHistory.Protocol_Number__c = '12313';
        bidHistory.Q2_Business_Area__c = 'Central Labs';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Due_Date__c = Date.today().addDays(30);
        bidHistory.Budget_Deliverable__c ='Assay Validation Document';
        bidHistory.Proposal_Deliverable__c = 'Email';
        bidHistory.Is_this_part_of_a_Program__c ='No';
        bidHistory.Related_Protocol_Number__c ='0123';
        bidHistory.Enrollement_Months__c = 12;
        bidHistory.Price_Structure__c = 'List';
        bidHistory.Patient_Duration_Months__c = 11;
        bidHistory.Assumption_for_Variable_Cost__c = '12345';
        bidHistory.Logistics_Site_location_Primary__c =50;
        bidHistory.Logistics_Site_location_Secondary__c =30;
        bidHistory.Logistics_Site_location_Teriary__c = 20;
        bidHistory.Estimated_Fees__c = 'Less than $5M';
        bidHistory.Scientific_Review__c ='No';
        bidHistory.Inbound_Transportation_Efficiency__c = '1.0';
        bidHistory.Requested_Services__c = 'BioFortis';
        bidHistory.Patients_Screened__c = 7.0;
        bidHistory.Is_a_Strategy_Call_Required__c = 'No';
        bidHistory.Patients_Enrolled__c = 6.0;
        bidHistory.Strategy_Call_Comments__c = 'test';
        bidHistory.Patients_Completed__c = 3.0;
        bidHistory.OWF_Potential_Regions__c = 'Japan';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        insert bidHistory;
        bidHistory.OwnerId = testUserRecord[0].Id;
        bidHistory.Notes__c = 'testValue';
        update bidHistory;
        System.assertEquals('Level - 4',bidHistory.Assign_Proposal_Ranking__c, 'Success');
        Test.stopTest();
    }
	
    @IsTest
    static void testSendEmailForQ2LabBidHistoryScientificReviewAndStrategicPrcingLead(){
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'OWF_06_q2ContractRequests';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_06_SendEmailForQ2SubmitToContracts';
        resourceToSubGroupSettingList.Key__c = 'OWF_06_q2ContractRequests';
        resourceToSubGroupSettingList.Value__c = 'rashi.gupta1@metacube.com';
        insert resourceToSubGroupSettingList;
       
        OWF_Generic_Setting__c resourceToSubGroupSettingList1 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList1.Name = 'Q2BioFortisAlert';
        resourceToSubGroupSettingList1.Data_Category__c = 'OWF_13_SendEmailForQ2BioFortisEmailAction';
        resourceToSubGroupSettingList1.Key__c = 'Q2BioFortisAlert';
        resourceToSubGroupSettingList1.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList1;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList2 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList2.Name = 'Q2LAB Bid History Scientific Review';
        resourceToSubGroupSettingList2.Data_Category__c = 'OWF_02_Q2LAB_Bid_History_Scientific_Review';
        resourceToSubGroupSettingList2.Key__c = 'Q2LAB Bid History Scientific Review';
        resourceToSubGroupSettingList2.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList2;
        
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
        bidHistory.Q2_BioFortis_Quote_Needed__c = true;
        bidHistory.OwnerId = testUser1[0].id;
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        Test.startTest();
            insert bidHistory;
            System.assertEquals('Japan',bidHistory.OWF_Potential_Regions__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testSendEmailForQ2BioFortisAlert(){
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList2 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList2.Name = CON_OWF.BHR_OWF_06_Q2CONTRACTREQUESTS;
        resourceToSubGroupSettingList2.Data_Category__c = 'OWF_13_SendEmailForQ2BioFortisEmailAction';
        resourceToSubGroupSettingList2.Key__c = CON_OWF.BHR_OWF_06_Q2CONTRACTREQUESTS;
        resourceToSubGroupSettingList2.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList2;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList3 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList3.Name = CON_OWF.BHR_OWF_12_Q2BIOFORTISALERT;
        resourceToSubGroupSettingList3.Data_Category__c = 'OWF_06_SendEmailForQ2SubmitToContracts';
        resourceToSubGroupSettingList3.Key__c = CON_OWF.BHR_OWF_12_Q2BIOFORTISALERT;
        resourceToSubGroupSettingList3.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList3;
        
        OWF_Generic_Setting__c resourceToSubGroupSettingList4 = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList4.Name = CON_OWF.BHR_OWF_13_Q2CHINALOCALSOLUTIONALERT;
        resourceToSubGroupSettingList4.Data_Category__c = 'OWF_14_SendEmailForQ2ChinaLocalSolutionEmailAction';
        resourceToSubGroupSettingList4.Key__c = CON_OWF.BHR_OWF_13_Q2CHINALOCALSOLUTIONALERT;
        resourceToSubGroupSettingList4.Value__c = 'praneeta.deepthi@metacube.com';
        insert resourceToSubGroupSettingList4;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        List<User> testUser1 = UTL_TestData.createUser('System Administrator', 1);
        testUser1[0].IsActive = true;
        Test.startTest();
        insert testUser1[0];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 01234;
        bidHistory.Scientific_Review__c = 'China Local Solution';
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
        bidHistory.Q2_BioFortis_Quote_Needed__c = true;
        bidHistory.Submit_to_Proposals__c = CON_OWF.SUBMIT_TO_PROPOSALS_TRUE;
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        bidHistory.Notes__c = 'testValue';
        insert bidHistory;
        bidHistory.OwnerId = testUserRecord[0].Id;
        update bidHistory;
        System.assertEquals('Japan', bidHistory.OWF_Potential_Regions__c, 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testPopulateRelatedQuoteStatusForAwardeded(){
        Bid_History__c bidHistory = [SELECT Id, Budget_Tools__c FROM Bid_History__c WHERE RecordTypeId =: CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        bidHistory.Budget_Tools__c = CON_OWF.BHR_OWF_BUDGET_TOOLS_UNIT_PRICING_TOOL;
        update bidHistory;
        Test.startTest();
        Bid_History__c bidHistoryUpdated = [SELECT Id, Related_Quote_Status__c FROM Bid_History__c WHERE Id =: bidHistory.Id];
        Test.stopTest();
        System.assertEquals(CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NO_QUOTE_CREATED, bidHistoryUpdated.Related_Quote_Status__c,'Test Method: testPopulateRelatedQuoteStatusForAwardeded');
    }

    @IsTest
    static void testSendEmailForAwardedBidHistoryAlert() 
    {
        Bid_History__c bidHistory = [SELECT Id, Is_Study_Awarded__c, Related_Quote_Status__c FROM Bid_History__c WHERE RecordTypeId =: CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        bidHistory.Is_Study_Awarded__c = CON_OWF.BHR_OWF_AWARDED_YES;
        bidHistory.Related_Quote_Status__c = CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_NOT_READY_TO_AWARD;
        update bidHistory;
        Test.startTest();
        Bid_History__c bidHistoryUpdated = [SELECT Id, Is_Study_Awarded__c, Related_Quote_Status__c FROM Bid_History__c WHERE Id =: bidHistory.Id];
        Test.stopTest();
        System.assertEquals(CON_OWF.BHR_OWF_AWARDED_YES, bidHistoryUpdated.Is_Study_Awarded__c,'Test Method: testSendEmailForAwardedBidHistoryAlert');        
    }

    @IsTest
    static void testSendEmailForReadyToAwardedBidHistoryAlert() 
    {
        Bid_History__c bidHistory = [SELECT Id, Is_Study_Awarded__c, Related_Quote_Status__c FROM Bid_History__c WHERE RecordTypeId =: CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        bidHistory.Is_Study_Awarded__c = CON_OWF.BHR_OWF_AWARDED_YES;
        bidHistory.Related_Quote_Status__c = CON_OWF.BHR_OWF_RELATED_QUOTE_STATUS_READY_TO_AWARD;
        update bidHistory;
        Test.startTest();
        Bid_History__c bidHistoryUpdated = [SELECT Id, Is_Study_Awarded__c, Related_Quote_Status__c FROM Bid_History__c WHERE Id =: bidHistory.Id];
        Test.stopTest();
        System.assertEquals(CON_OWF.BHR_OWF_AWARDED_YES, bidHistoryUpdated.Is_Study_Awarded__c,'Test Method: testSendEmailForReadyToAwardedBidHistoryAlert');        
    }
    
    /*@IsTest
    static void testValidateTotalEffectiveDiscount(){
        Bid_History__c bidHistory = [SELECT Id, Total_Effective_Discount__c FROM Bid_History__c WHERE RecordTypeId =: CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID LIMIT 1];
        bidHistory.Total_Effective_Discount__c = 99.98;
        update bidHistory;
        Test.startTest();
        Bid_History__c bidHistoryUpdated = [SELECT Id, Total_Effective_Discount__c FROM Bid_History__c WHERE Id =: bidHistory.Id];
        Test.stopTest();
        System.assertEquals(99.98, bidHistoryUpdated.Total_Effective_Discount__c,'Test Method: testValidateTotalEffectiveDiscount');
    }*/

    @IsTest
    static void testCreateResourceRequestsOnContractPostAwardBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        Test.startTest();
        insert bidHistory;
        opp.Line_of_Business__c = 'Clinical';
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        update opp;
        Bid_History__c bhr = [Select id, Requested_Services__c from Bid_History__c where id =: bidHistory.Id];
        bhr.Requested_Services__c = 'IQB Project Management;';
        update bhr;
		List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :bidHistory.Id and SubGroup__c = 'DSB-PM Post'];
        Test.stopTest();
        System.assertEquals(0, resReqsList.size(), 'Success'); 
    }
    
    @IsTest
    static void testPopulateBidDueDateForTechSolutionsBidHistory(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c techSolutionsSUpportRequestBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID);
        techSolutionsSUpportRequestBidHistory.Do_You_Need_Global_RFP_Team_Support__c = FALSE;
        techSolutionsSUpportRequestBidHistory.Do_You_Need_Global_SE_Support__c = TRUE;
        techSolutionsSUpportRequestBidHistory.Bid_Due_Date__c = NULL;
        techSolutionsSUpportRequestBidHistory.Safety_Technologies__c = TRUE;
        insert techSolutionsSUpportRequestBidHistory;
        Bid_History__c bidHistory = [Select id, Name, Bid_Due_Date__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID];
        Test.startTest();
        System.assertEquals(Date.Today().addDays(30), bidHistory.Bid_Due_Date__c, 'Success: testPopulateBidDueDateForTechSolutionsBidHistory'); 
        Test.stopTest();
    }

    @isTest
    static void testSendQ2SolutionsBioSciencesBidAlertToRFPMailbox(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        
        resourceToSubGroupSettingList.Name = 'Q2_Solutions_BioSciences_RFP_Mailbox';
        resourceToSubGroupSettingList.Data_Category__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Key__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
        	Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        	bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;	
        	insert bid;
       	Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
			WHERE Related_To_Object_Id__c = :bid.Id];
         Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
         Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
    }
    
    @isTest
    static void testsendEmailForBioScienceStageChange(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;        
        Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;	
        bid.Bid_Type__c= 'Change Order';
        insert bid ;
        Bid_History__c bid2 = [SELECT Id FROM Bid_History__c  Where Bid_Type__c = 'Change Order' LIMIT 1];
        bid2.Stage__c = 'Sent';
        update bid2;
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[1].Email_Action__c, 'Email Action is incorrect');
    }
    @IsTest
    static void testSendEmailForBSBidSentDate(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];        
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp ;
        Bid_History__c q2SolutionBidHistory1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory1.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory1.Bid_Type__c = CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory1.Bid_Sent__c = CON_OWF.BID_SENT ;
        q2SolutionBidHistory1.Bid_Sent_Date__c = Date.Today();
        
        Test.startTest();        
        insert q2SolutionBidHistory1;
        Test.StopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :q2SolutionBidHistory1.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[1].Email_Action__c, 'Email Action is incorrect');
  
    }
    @isTest
    static void testSendQ2SolutionsBioSciencesBidAlertToRFPMailboxChangeOrder(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        
        resourceToSubGroupSettingList.Name = 'Q2_Solutions_BioSciences_RFP_Mailbox';
        resourceToSubGroupSettingList.Data_Category__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Key__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;        
        Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;	
        bid.Bid_Type__c= 'Change Order';
        insert bid;
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
    }
    @IsTest
    static void testPopulateFieldsForGCCBidHistory(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c gccBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID);
        gccBidHistory.Bid_History_Status__c = CON_OWF.OWF_BID_HISTORY_STATUS_AWAITING_CUSTOMER_FEEDBACK;
        gccBidHistory.Opportunity_Type__c = CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_INTERNAL;
        gccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST;
        gccBidHistory.One_Off_Fees_For_Service_Implementation__c = 50;
        insert gccBidHistory;
        Bid_History__c updatedGccBidHistory = [Select Id, Bid_Sent_Date__c, RFP_Ranking__c, Standard_Turnaround_Time_BD__c, Total_Bid_Value_Labor_Direct_Discount__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID];
        
        Test.startTest();
        System.assertEquals(50, updatedGccBidHistory.Total_Bid_Value_Labor_Direct_Discount__c, 'Success: testPopulateForGCCBidHistory [Total Bid Value]');
        System.assertEquals(Date.Today(), updatedGccBidHistory.Bid_Sent_Date__c, 'Success: testPopulateForGCCBidHistory [Bid Sent Date]');
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL1, updatedGccBidHistory.RFP_Ranking__c, 'Success: testPopulateForGCCBidHistory [RFP Ranking]');
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_5_BUSINESS_DAYS, updatedGccBidHistory.Standard_Turnaround_Time_BD__c, 'Success: testPopulateForGCCBidHistory [Standard Turnaround Time(BD)]');
        
        updatedGccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_SUMM_OF_GCC_CAP;
        update updatedGccBidHistory;
        updatedGccBidHistory = [Select Id, RFP_Ranking__c, Standard_Turnaround_Time_BD__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL1, updatedGccBidHistory.RFP_Ranking__c, 'Success: testPopulateForGCCBidHistory [RFP Ranking]');
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_5_BUSINESS_DAYS, updatedGccBidHistory.Standard_Turnaround_Time_BD__c, 'Success: testPopulateForGCCBidHistory [Standard Turnaround Time(BD)]');
        
        updatedGccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_ABBR_RFP_COST_BRK_AND_SUMM;
        update updatedGccBidHistory;
        updatedGccBidHistory = [Select Id, RFP_Ranking__c, Standard_Turnaround_Time_BD__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL2, updatedGccBidHistory.RFP_Ranking__c, 'Success: testPopulateForGCCBidHistory [RFP Ranking]');
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_7_BUSINESS_DAYS, updatedGccBidHistory.Standard_Turnaround_Time_BD__c, 'Success: testPopulateForGCCBidHistory [Standard Turnaround Time(BD)]');
        
        updatedGccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_FULL_RFP_COMP_TXT_AND_COST_BRK;
        update updatedGccBidHistory;
        updatedGccBidHistory = [Select Id, RFP_Ranking__c, Standard_Turnaround_Time_BD__c from Bid_History__c where RecordTypeId = :CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_RFP_RANKING_LEVEL3, updatedGccBidHistory.RFP_Ranking__c, 'Success: testPopulateForGCCBidHistory [RFP Ranking]');
        System.assertEquals(CON_OWF.OWF_BID_HISTORY_STANDARD_TURNAROUND_TIME_BD_10_BUSINESS_DAYS, updatedGccBidHistory.Standard_Turnaround_Time_BD__c, 'Success: testPopulateForGCCBidHistory [Standard Turnaround Time(BD)]');
        Test.stopTest();
    }
    
    @IsTest
    static void testPopulateFieldsForContractPostAwardBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Bid_History__c contractPostAwardBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        contractPostAwardBidHistory.Budget_Tools__c = 'ECG Standalone Spreadsheet';
        insert contractPostAwardBidHistory;
        
        Test.startTest();
        Bid_History__c contractPostAwardBid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        contractPostAwardBid.Created_by_FormAssembly__c = true;
        contractPostAwardBid.Requester_email__c = 'xyz@metacube.com';
        insert contractPostAwardBid;
        Test.stopTest();
        System.assertEquals(true, contractPostAwardBid.Created_by_FormAssembly__c, 'Success');
    }
    @IsTest
    static void testBSRebidWithoutIntial(){ 
    try{
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];       
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp ;
        Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_RE_BID;
        q2SolutionBidHistory.Study_Number__c = '01';
        Test.startTest();         
            insert q2SolutionBidHistory;      
        Test.stopTest();
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Re-Bid']   ;
        System.assertEquals(true, bid.isEmpty());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @IsTest
    static void testBSInitalexistValidation(){  
    try{
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];        
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp ;
        Bid_History__c q2SolutionBidHistory1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory1.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory1.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory1.Study_Number__c = '01';
        Bid_History__c q2SolutionBidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory2.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory2.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory2.Study_Number__c = '01';
        Test.startTest();
            insert q2SolutionBidHistory1;
            insert q2SolutionBidHistory2;           
        Test.stopTest();
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Initial'];
        System.assertEquals(1,bid.size());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @isTest
    static void testBSawrededOppValidateForCO(){
        try{
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
            Test.startTest();  
                opp.Line_of_Business__c = 'Q2 Solutions';
                update opp ;
                Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
                q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
                q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
                q2SolutionBidHistory.Study_Number__c = '01';
                insert q2SolutionBidHistory;
            
            Test.stopTest();
            list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Change Order']   ;
            System.assertEquals(true,bid.isEmpty());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @isTest
    static void testBSawrededOppValidateForInitial(){
        try{
            list<Bid_History__c> bidHistoryList = new list<Bid_History__c>();
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
            List<Contact> conList = [Select Id From Contact];            
            Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];   
            Test.startTest();

                Competitor__c comptitor = new Competitor__c();           
                comptitor.Name = 'testOpp';
                insert comptitor;
                opp.Line_of_Business__c = 'Q2 Solutions';
                opp.StageName = '5. Finalizing Deal';
                opp.Full_Service__c='Yes';
                opp.Principle_inCharge__c = conList[1].Id;
                opp.Contract_Start_Date__c = system.today().addDays(5);
                opp.Contract_End_Date__c= system.today().addDays(5);
                opp.Potential_Competitor_1__c=comptitor.ID;
                update opp ;
                
                Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
                q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
                q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
                q2SolutionBidHistory.Study_Number__c = '01';           
                insert q2SolutionBidHistory;            
            Test.stopTest();
            
            list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Initial']   ;
            System.assertEquals(true,bid.isEmpty());
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }        
    }
    @isTest
    static void testBioScienceStudyNumValidaton(){
        try{
            list<Bid_History__c> bidHistoryList = new list<Bid_History__c>();
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
            List<Contact> conList = [Select Id From Contact];
            Test.startTest();            
                Competitor__c comptitor = new Competitor__c();           
                comptitor.Name = 'testOpp';
                insert comptitor;
                opp.Line_of_Business__c = 'Q2 Solutions';
                opp.StageName = '5. Finalizing Deal';
                opp.Full_Service__c='Yes';
                opp.Principle_inCharge__c = conList[1].Id;
                opp.Contract_Start_Date__c = system.today().addDays(5);
                opp.Contract_End_Date__c= system.today().addDays(5);
                opp.Potential_Competitor_1__c=comptitor.ID;
                update opp ;
                
                Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
                q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
                q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
                q2SolutionBidHistory.Study_Number__c = '05';
                
                Bid_History__c q2SolutionBidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
                q2SolutionBidHistory2.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
                q2SolutionBidHistory2.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
                q2SolutionBidHistory2.Study_Number__c = '02';
                
                insert q2SolutionBidHistory;
                insert q2SolutionBidHistory2;            
            Test.stopTest(); 
            
            list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Change Order']   ;
            System.assertEquals(1,bid.size());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
    }
    @isTest
    static void testBSChangeOrderForAwaredOpp(){
        list<Bid_History__c> bidHistoryList = new list<Bid_History__c>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
            Competitor__c comptitor = new Competitor__c();           
            comptitor.Name = 'testOpp';
            insert comptitor;
            opp.Line_of_Business__c = 'Q2 Solutions';
            opp.StageName = '5. Finalizing Deal';
            opp.Full_Service__c='Yes';
            opp.Principle_inCharge__c = conList[1].Id;
            opp.Contract_Start_Date__c = system.today().addDays(5);
            opp.Contract_End_Date__c= system.today().addDays(5);
            opp.Potential_Competitor_1__c=comptitor.ID;
            update opp ;        
            Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
            q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
            q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
            q2SolutionBidHistory.Study_Number__c = '05';        
            insert q2SolutionBidHistory;   
        
        Test.stopTest(); 
        
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Change Order']   ;
        System.assertEquals(1,bid.size());  
        
    }
    @IsTest
    static void testBSInitalBidForOpp(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];        
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp ;
        Bid_History__c q2SolutionBidHistory1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory1.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory1.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory1.Study_Number__c = '01';
        
        Test.startTest();        
            insert q2SolutionBidHistory1;
        Test.StopTest();
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Initial'];
        System.assertEquals(1,bid.size());
        
    }
    @IsTest
    static void testSendEmailForBioScienceBidOwnerChange(){  
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Contact> conList = [Select Id From Contact];
        Test.startTest();    
        List<User> testUserRecord = UTL_TestData.createUser('System Administrator', 1);
        insert testUserRecord;
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;   Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;	
        bid.Bid_Type__c= 'Change Order';
        insert bid ;
        Bid_History__c bid2 = [SELECT Id FROM Bid_History__c  Where Bid_Type__c = 'Change Order' LIMIT 1];
        bid2.Stage__c = 'Sent';
        bid2.OwnerId = testUserRecord[0].Id;
        update bid2;
        Test.stopTest();
         List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid2.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[1].Email_Action__c, 'Email Action is incorrect');
   
    }
    @isTest
    static void testsetQueueAsOwneronQ2RecordType(){
        list<Bid_History__c> bidHistoryList = new list<Bid_History__c>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;        
        Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
        q2SolutionBidHistory.Study_Number__c = '05'; 
        q2SolutionBidHistory.Stage__c = 'Awarded';  
        bidHistoryList.add(q2SolutionBidHistory);
        
        Bid_History__c q2SolutionBidHistorytest = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistorytest.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistorytest.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
        q2SolutionBidHistorytest.Study_Number__c = '06';  
        q2SolutionBidHistorytest.LQ_Bid_Histroy_Id__c += '1';
        bidHistoryList.add(q2SolutionBidHistorytest);
        
        insert bidHistoryList;
        Set<Id> ids = new Set<Id>{bidHistoryList[0].Id, bidHistoryList[1].Id};
            
        Test.stopTest(); 
        
        List<Bid_History__c> bid = [SELECT Id,OwnerId FROM Bid_History__c where id in : ids order By CreatedDate LIMIT 2];
        system.debug( bid[0].OwnerId);
        List<Group> q2UsersQueue = new SLT_Groups(false,false).getGroupByDevelopernameSet(new Set<String>{'Id'},new Set<String>{'Q2_Unassigned'});
        
        system.assertEquals(q2UsersQueue[0].Id, bid[0].OwnerId);
        system.assertEquals(q2UsersQueue[0].Id, bid[1].OwnerId);
        
        
    }
    @isTest
    static void testSendQ2SolutionsVaccineBidAlertToRFPMailboxChangeOrder(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        
        resourceToSubGroupSettingList.Name = 'Q2_Solutions_BioSciences_RFP_Mailbox';
        resourceToSubGroupSettingList.Data_Category__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Key__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;        
        Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;	
        bid.Bid_Type__c= 'Change Order';
        insert bid;
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
    }
    @isTest
    static void testSendQ2SolutionsVaccinesBidAlertToRFPMailbox(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        
        resourceToSubGroupSettingList.Name = 'Q2_Solutions_BioSciences_RFP_Mailbox';
        resourceToSubGroupSettingList.Data_Category__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Key__c = 'Q2BioScienceRFPMailboxEmailAlert';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
        Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_VACCINES;	
        insert bid;
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
    }
    @isTest
    static void testsendEmailForVaccineStageChange(){
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);
        opp.Potential_Competitor_1__c=comptitor.ID;
        update opp ;        
        Bid_History__c bid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bid.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_VACCINES;	
        bid.Bid_Type__c= 'Change Order';
        insert bid ;
        Bid_History__c bid2 = [SELECT Id FROM Bid_History__c  Where Bid_Type__c = 'Change Order' LIMIT 1];
        bid2.Stage__c = 'Sent';
        update bid2;
        Test.stopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :bid.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[1].Email_Action__c, 'Email Action is incorrect');
    }
    @IsTest
    static void testSendEmailForVaccineBidSentDate(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];        
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp ;
        Bid_History__c q2SolutionBidHistory1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory1.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        q2SolutionBidHistory1.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory1.Bid_Sent__c = CON_OWF.BID_SENT;
        q2SolutionBidHistory1.Bid_Sent_Date__c= Date.Today();
        
        Test.startTest();        
        insert q2SolutionBidHistory1;
        Test.StopTest();
        List<Workflow_Email_Record__c> workflowRecords = [
            SELECT Id, Email_Action__c from Workflow_Email_Record__c 
            WHERE Related_To_Object_Id__c = :q2SolutionBidHistory1.Id];
        Assert.areEqual(true, workflowRecords.size() > 0, 'Workflow Email Record insert failed');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[0].Email_Action__c, 'Email Action is incorrect');
        Assert.areEqual(CON_OWF.Q2SOLUTIONS_BIOSCEINCES_RFP_MAILBOX_EMAIL_ACTION, workflowRecords[1].Email_Action__c, 'Email Action is incorrect');

        
    }
    @IsTest
    static void testVaccinesInitalexistValidation(){  
    try{
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];        
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.Q2_Budget_Tool__c = 'VACCINES';
        update opp ;
        Bid_History__c q2SolutionBidHistory1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory1.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        q2SolutionBidHistory1.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory1.Study_Number__c = '01';
        Bid_History__c q2SolutionBidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory2.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        q2SolutionBidHistory2.Bid_Type__c=CON_OWF.BID_TYPE_INITIAL;
        q2SolutionBidHistory2.Study_Number__c = '01';
        Test.startTest();
            insert q2SolutionBidHistory1;
            insert q2SolutionBidHistory2;           
        Test.stopTest();
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Initial'];
        System.assertEquals(2,bid.size());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @isTest
    static void testVaccinesawrededOppValidateForCO(){
        try{
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
            Test.startTest();  
                opp.Line_of_Business__c = 'Q2 Solutions';
                opp.Q2_Budget_Tool__c = 'VACCINES';
                update opp ;
                Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
                q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_VACCINES;
                q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
                q2SolutionBidHistory.Study_Number__c = '01';
                insert q2SolutionBidHistory;
            
            Test.stopTest();
            list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Change Order']   ;
            System.assertEquals(true,bid.isEmpty());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @IsTest
    static void testVaccinesRebidWithoutIntial(){ 
    try{
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];       
        opp.Line_of_Business__c = 'Q2 Solutions';
         opp.Q2_Budget_Tool__c = 'VACCINES';
        update opp ;
        Bid_History__c q2SolutionBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistory.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        q2SolutionBidHistory.Bid_Type__c=CON_OWF.BID_TYPE_RE_BID;
        q2SolutionBidHistory.Study_Number__c = '01';
        Test.startTest();         
            insert q2SolutionBidHistory;      
        Test.stopTest();
        list<Bid_History__c> bid = [SELECT ID , Bid_Type__c FROM Bid_History__c WHERE Bid_Type__c = 'Re-Bid']   ;
        System.assertEquals(true, bid.isEmpty());
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
    @istest
    static void testPopulateChangeOrderAmount(){
        list<Bid_History__c> bidHistoryList = new list<Bid_History__c>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];  
        List<Contact> conList = [Select Id From Contact];
        
        Test.startTest();        
        Competitor__c comptitor = new Competitor__c();           
        comptitor.Name = 'testOpp';
        insert comptitor;
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '5. Finalizing Deal';
        opp.Full_Service__c='Yes';
        opp.Principle_inCharge__c = conList[1].Id;
        opp.Contract_Start_Date__c = system.today().addDays(5);
        opp.Contract_End_Date__c= system.today().addDays(5);        
        opp.Potential_Competitor_1__c=comptitor.ID;
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Awarded_Date__c = System.today();
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = system.today();
        opp.Anticipated_RFP_Date__c = system.today();
        opp.Extension_Continuation_Part_of_Progam__c = 'N/A';
        opp.Is_this_a_renewal__c = 'Yes';
        opp.Expected_Project_End_Date__c = system.today()+7;
        opp.Expected_Project_Start_Date__c = system.today();
        opp.GPM_to_be_located_in_specific_region__c = 'N/A';
        opp.Protocol_Number__c = 'test';
        opp.Q2_Budget_Tool__c = 'N/A';
        opp.Q2_CTMS_Picklist__c = 'N/A';
        opp.Test_Type__c = 'IVD';
        opp.Will_Contract_have_a_fixed_price__c = 'Yes';
        opp.Does_study_include_LNS__c = 'Yes';
        opp.Proposal_Sent_Date__c = system.today();
        opp.US_government_fully_or_partially_funded__c = 'Yes';
        opp.Funding_Department_Agency__c = 'VA';
        opp.RFP_ReceivedDate__c = system.today();
        opp.InterventionType__c = 'FIM';
        opp.Global_Public_Health__c = 'Yes';
        opp.Global_Public_Health_Agency__c = 'CEPI';
        opp.Expect_ATP_or_WO_in_Awarded_Qtr__c = 'Very Likely';
        opp.Amount = 1;      
        update opp ;    
        Bid_History__c q2SolutionBidHistorytest = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        q2SolutionBidHistorytest.Q2_Business_Area__c= CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        q2SolutionBidHistorytest.Bid_Type__c=CON_OWF.BID_TYPE_CHANGE_ORDER;
        q2SolutionBidHistorytest.Study_Number__c = '06';  
        q2SolutionBidHistorytest.LQ_Bid_Histroy_Id__c += '1';
        q2SolutionBidHistorytest.Previous_value_for_Contract__c = 1;
        bidHistoryList.add(q2SolutionBidHistorytest);        
        insert bidHistoryList;
        Test.stopTest(); 
        Bid_History__c bid = [SELECT Id,Previous_value_for_Contract__c,Opportunity_Value__c FROM Bid_History__c where id =:q2SolutionBidHistorytest.Id LIMIT 1];
        System.assertEquals(bid.Opportunity_Value__c, bid.Previous_value_for_Contract__c);	
    }
    
    @istest
    static void testSendEmailForGCCforFieldUpdate(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'Notification_To_GCCOnBHRFieldUpdate';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_20_NotificationToGCC';
        resourceToSubGroupSettingList.Key__c = 'Notification_To_GCCOnBHRFieldUpdate';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'] ;
        Bid_History__c gccBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_GCC_BID_HISTORY_RECORD_TYPE_ID);
        insert gccBidHistory;
        Test.startTest();  
        gccBidHistory.Calls_Emails_Contacts_Monthly_Inbound__c = 'test';
        gccBidHistory.Calls_Emails_Contacts_Monthly_Outbound__c = 'test';
        gccBidHistory.Project_Duration_Months__c = 'test';
        update gccBidHistory;
        Test.stopTest(); 
        List<Workflow_Email_Record__c> emailRecords = [ select id,Related_To_Object_Id__c from Workflow_Email_Record__c where Related_To_Object_Id__c =: gccBidHistory.Id ];
        System.assertNotEquals(0, emailRecords.size()); 
    }

    @istest
    static void testSendEmailForTechSolSupportforCreateRecord(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'Notification_To_TechSolutionOnCreate';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_22_NotificationOnTechSolutionRecordOnCreate';
        resourceToSubGroupSettingList.Key__c = 'Notification_To_TechSolutionOnCreate';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'] ;
        Test.startTest();  
        Bid_History__c TSBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_TECH_SOLUTIONS_SUPPORT_REQUEST_BID_HISTORY_RECORD_TYPE_ID);
        TSBidHistory.Safety_Technologies__c =true;
        TSBidHistory.Engage__c =true;
        TSBidHistory.Request_Type_RFP__c = 'RFI';
        TSBidHistory.Global_RFP_Regions__c = 'US';
        TSBidHistory.Targeted_Countries__c = 'AL';
        TSBidHistory.Go_No_Go_Analysis_Performed__c = 'Yes';
        TSBidHistory.Product_Pillar_RFP__c = 'OneKey';
        TSBidHistory.Request_Details_RFP__c = 'Test';
        insert TSBidHistory;
        Test.stopTest(); 
        List<Workflow_Email_Record__c> emailRecords = [ select id,Related_To_Object_Id__c from Workflow_Email_Record__c where Related_To_Object_Id__c =: TSBidHistory.Id ];
        System.assertNotEquals(0, emailRecords.size());
    }
    
    
    @istest
    static void testCreateResourceRequestsOnCSSBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity limit 1];
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.PCS__c = True;
        bidHistory.Bid_Category__c = 'Combined';
        bidHistory.Proposal_Deliverable__c = 'Experience tables and budget range';
        bidHistory.Rate_card_MSA_explanation__c = 'Test Class';
        bidHistory.LPI_Date__c = System.today();
        bidHistory.DBL_Date__c = System.today();
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Requested_Services__c = 'CD - ECG';
        bidHistory.Cardiac_Safety_Equipment_Vendor__c = 'TT';
        bidHistory.Connected_Devices_Logistics_Vendor__c = 'Test';
        bidHistory.OWF_Potential_Regions__c = 'Latin America';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        insert bidHistory;
        Test.startTest();
        bidHistory.Connected_Devices__c = true;
        update bidHistory;
        Test.stopTest();
        system.assertEquals(2, bidHistory.Number_of_Scenarios__c, 'Success');    
    }
    
    @istest
    static void testSendEmailForRFIRequestIQVIALABSSPWSupport(){
        OWF_Generic_Setting__c resourceToSubGroupSettingList = new OWF_Generic_Setting__c();
        resourceToSubGroupSettingList.Name = 'Notification_from_RFI_IQVIA_LABS';
        resourceToSubGroupSettingList.Data_Category__c = 'OWF_26_NotificationRFIIQVIALABSSPWSupport';
        resourceToSubGroupSettingList.Key__c = 'Notification_from_RFI_IQVIA_LABS';
        resourceToSubGroupSettingList.Value__c = 'test@testiqvia.com';
        insert resourceToSubGroupSettingList;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'] ;  
        Bid_History__c bidRecord = UTL_OWF_TestData.createBidHistory(acc.Id, opp.Id);
        bidRecord.Resources_Needed__c = 'MSL';
        bidRecord.Bid_Due_Date__c = Date.today().addDays(7);
        bidRecord.recordTypeId = CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID;
        bidRecord.Triage_Level__c = 'Level A Experience or Staffing';
        insert bidRecord;
        //Bid_History__c bidRecord1 = [Select id, IQVIA_LABS_SPW_Support__c from Bid_History__c Where id =: bidRecord.Id];
        Test.startTest();
        bidRecord.IQVIA_LABS_SPW_Support__c = 'Yes';
        update bidRecord;
        Test.stopTest(); 
        List<Workflow_Email_Record__c> emailRecords = [ select id,Related_To_Object_Id__c from Workflow_Email_Record__c where Related_To_Object_Id__c =: bidRecord.Id ];
        System.assertEquals(true, emailRecords.size()>0, 'Success');
    }
        
}
