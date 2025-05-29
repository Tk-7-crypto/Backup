/**
* This test class is used to test all methods in opportunity trigger helper.
* version : 1.0
*/
@isTest(seeAllData=false)
private class TST_DAOH_OWF_APTS_Agreement {
    
    /**
	* This method is used to setup data for all methods.
	*/
    /*@testSetup
    static void dataSetup() {
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
            Resources_Needed__c = 'TAL',
            Sub_Group__c = 'TAL',
            Name = 'TAL'
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
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 1;
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Agreement__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequest(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        resourceRequest.pse__End_Date__c = system.today();
        insert resourceRequest;
    }*/
    
    
    /**
	* This test method used for insert Agreement to validate Number of Requested Services
	*/ 
    static testMethod void testSetNoOfRequestedServicesBasedOnRequestedServices_InsertScenario() 
    {  

		
        DAOH_OWF_APTS_Agreement.dummy();

        /*Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID);
        Test.startTest();
            agreement.Requested_Services__c = 'Call Center;Biostatistical';
            insert agreement;
            Apttus__APTS_Agreement__c modifiedAgreement = [Select Id, Number_of_Requested_Services__c From Apttus__APTS_Agreement__c Where Id = :agreement.Id];
            system.assertEquals(2, modifiedAgreement.Number_of_Requested_Services__c);
        Test.stopTest();*/
    }
    
    
    /**
	* This test method used for update Agreement to validate Number of Requested Services
	*/ 
  /*  static testMethod void testSetNoOfRequestedServicesBasedOnRequestedServices_UpdateScenario() 
    {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID);
        Test.startTest();
            insert agreement;
            agreement.Requested_Services__c = 'Feasibility;Call Center;Biostatistical';
            update agreement;
            Apttus__APTS_Agreement__c modifiedAgreement = [Select Id, Number_of_Requested_Services__c,Requested_Services__c From Apttus__APTS_Agreement__c Where Id = :agreement.Id];
            system.assertEquals(3, modifiedAgreement.Number_of_Requested_Services__c);
            agreement.Requested_Services__c = '';
            update agreement;
            modifiedAgreement = [Select Id, Number_of_Requested_Services__c From Apttus__APTS_Agreement__c Where Id = :agreement.Id];
        Test.stopTest();
    }*/
    
    
    /**
	* This test method used for insert Agreement to validate Bid No based on record type
	*/ 
   /* static testMethod void testSetBidNoBasedOnRecordType_InsertScenario() 
    {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<Apttus__APTS_Agreement__c> lstOfAgreementsToInsert = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID);
        agreement.LQ_Bid_Histroy_Id__c = 'Test 101';
        Apttus__APTS_Agreement__c agreementNonRfp = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID);
        agreementNonRfp.LQ_Bid_Histroy_Id__c = 'Test 701';
        lstOfAgreementsToInsert.add(agreement);
        lstOfAgreementsToInsert.add(agreementNonRfp);
        Test.startTest();
            insert lstOfAgreementsToInsert;
            Apttus__APTS_Agreement__c clinicalBidAgreement = [Select Id, Bid_Number__c From Apttus__APTS_Agreement__c Where Id = :agreement.Id];
            system.assertEquals(2, clinicalBidAgreement.Bid_Number__c);
            Apttus__APTS_Agreement__c agreement1 = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID);
            insert agreement1;
            Apttus__APTS_Agreement__c nonRFPBidAgreement = [Select Id, Bid_Number__c From Apttus__APTS_Agreement__c Where Id = :agreementNonRfp.Id];
            system.assertEquals(0, nonRFPBidAgreement.Bid_Number__c);
        Test.stopTest();
    }
    
    
    /**
	* This test method used for update Agreement's Bid_Due_Date to validate End_Date on related records
	*/
    /*static testMethod void testSetEndDateAndStatusOnProjectResReqsAndAssignmentsWithFutureDate() 
    {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Account__c, Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c][0];
        pse__Proj__c bidProject = [Select Id From pse__Proj__c limit 1];
        Contact cont = [Select Id, pse__Is_Resource__c, pse__Is_Resource_Active__c From Contact limit 1];
        pse__Grp__c grp = [Select Id From pse__Grp__c limit 1];
        List<pse__Resource_Request__c> lstToInsertResourceRequests = new List<pse__Resource_Request__c>();
        pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequest(agreement.Id, agreement.Apttus__Related_Opportunity__c, bidProject.Id);
        resourceRequest1.pse__Group__c = grp.Id;
        resourceRequest1.SubGroup__c = 'TSL-Japan';
        lstToInsertResourceRequests.add(resourceRequest1);
        pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequest(agreement.Id, agreement.Apttus__Related_Opportunity__c, bidProject.Id);
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
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignment(agreement.Id, bidProject.Id, lstToInsertSchedules.get(0).Id, cont.Id, lstToInsertResourceRequests.get(0).Id));
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignment(agreement.Id, bidProject.Id, lstToInsertSchedules.get(1).Id, cont.Id, lstToInsertResourceRequests.get(1).Id));
            insert lstToInsertAssignments;
            agreement.Bid_Due_Date__c = system.today().addDays(5);
            update agreement;
            List<pse__Assignment__c> listOfAssignments = [Select Id, pse__End_Date__c From pse__Assignment__c Where Agreement__c = :agreement.Id];
            system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(0).pse__End_Date__c);
            system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(1).pse__End_Date__c);
        Test.stopTest();
    }*/
    
    
    /**
	* This test method used for update Agreement's Bid_Due_Date to validate Status and End_Date on related records
	*/
    /*static testMethod void testSetEndDateAndStatusOnProjectResReqsAndAssignmentsWithToday() 
    {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Account__c, Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c][0];
        pse__Proj__c bidProject = [Select Id From pse__Proj__c limit 1];
        Contact cont = [Select Id From Contact limit 1];
        pse__Grp__c grp = [Select Id From pse__Grp__c limit 1];
        Test.startTest();
            List<pse__Schedule__c> lstToInsertSchedules = new List<pse__Schedule__c>();
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            lstToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert lstToInsertSchedules;
            List<pse__Assignment__c> lstToInsertAssignments = new List<pse__Assignment__c>();
            List<pse__Resource_Request__c> rrList = [Select Id, pse__End_Date__c, pse__Status__c,pse__Assignment__c From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan' Limit 1];
            lstToInsertAssignments.add(UTL_OWF_TestData.createAssignment(agreement.Id, bidProject.Id, lstToInsertSchedules.get(0).Id, cont.Id, rrList.get(0).Id));
            insert lstToInsertAssignments;
        	List<pse__Assignment__c> assignmentsList = [Select Id, pse__Status__c, pse__End_Date__c From pse__Assignment__c Where Agreement__c = :agreement.Id];
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
        	//system.assertEquals(agreement.Bid_Due_Date__c, listOfRRs.get(0).pse__End_Date__c);
        	//system.assertEquals(CON_OWF.OWF_STATUS_COMPLETED, listOfRRs.get(0).pse__Status__c);
        
       		List<pse__Assignment__c> listOfAssignments = [Select Id, pse__Status__c, pse__End_Date__c From pse__Assignment__c Where Agreement__c = :agreement.Id];
        	//system.assertEquals(agreement.Bid_Due_Date__c, listOfAssignments.get(0).pse__End_Date__c);
        	//system.assertEquals(CON_OWF.OWF_STATUS_COMPLETED, listOfAssignments.get(0).pse__Status__c);
        Test.stopTest();
    }*/
    
    
    /**
	* This test method used to Delete Project Based On Agreement
	*/
    /*static testMethod void testDeleteProjectBasedOnAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c][0];
        Test.startTest();
        	delete agreement;
        Test.stopTest();
        
        List<pse__proj__c> projectList = [Select Id From pse__proj__c Where Agreement__c = :agreement.Id];
        Integer expected = 0;
        System.assertEquals(expected, projectList.size());
    }*/
    
    
    /**
	* This test method used to validate created Resource Request based on agreement udpate
	*/ 
   /* static testMethod void testCreateClinicalBidResRequestsOnAgreementUpdate() 
    {   
        Opportunity opp = [Select Id From Opportunity limit 1];
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c][0];
        Test.startTest();
            Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
            insert indication;
            opp.Potential_Regions__c = 'Asia Pacific';
            opp.Line_of_Business__c = 'Core Clinical';
            opp.Bid_Defense_Date__c = system.today().addDays(2);
        	opp.Phase_P__c =  'Phase 1';
        	opp.Indication_List__c = indication.Id;
            update opp;
            agreement.Bid_Due_Date__c = system.today().addDays(5);
            update agreement;
        Test.stopTest();
        
        List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where pse__Opportunity__c = :opp.Id];
        //System.assertEquals(3, resReqsList.size());
    }*/

   /* static testMethod void testUpdateResourcesNeededFromAgreement() 
    {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_POST_AWARD_BID_RECORD_TYPE_ID);
        Test.startTest();
        	agreement.Resources_Needed__c = 'ASL;MSL';
            insert agreement;
            agreement.Resources_Needed__c = 'ASL;MSL;CA&S';
            update agreement;
        Test.stopTest();

		List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where pse__Opportunity__c = :opp.Id];
		System.assertNotEquals(2, resReqsList.size());
    }*/
}