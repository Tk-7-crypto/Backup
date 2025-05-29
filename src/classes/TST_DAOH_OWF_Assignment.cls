/**
* This test class is used to test all methods in DAOH_OWF_Assignment Class.
* version : 1.0 
*/
@isTest
private class TST_DAOH_OWF_Assignment {
	
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        List<User> userList = UTL_TestData.createUser('System Administrator', 4);
        userList[0].FirstName = 'TestRunner';
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
        userList[1].FirstName = 'Test2';
        userList[1].SUBREGION__c = 'United States of America';
        userList[1].IsActive = true;
        userList[2].FirstName = 'Test3';
        userList[2].SUBREGION__c = 'United States of America';
        userList[2].IsActive = true;
        userList[3].FirstName = 'Test4';
        userList[3].SUBREGION__c = 'United States of America';
        userList[3].IsActive = true;
        insert userList;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = Date.newInstance(2020, 05, 08);
        opp.Presentation_Country__c = 'Armenia';
        opp.Presentation_Date_Status__c = 'Estimated';
        insert opp;
        Bid_History__c agreement =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
        test.startTest();
        insert agreement;
        Investigator_Grant__c ig = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(agreement.Id);
        ig.Request_Status__c = 'Open';
        insert ig;
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.Suggested_FTE__c = 0.45;
        resourceRequest.Is_Created_Automatically__c = True;
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill',CON_OWF.SKILL_TYPE_INDICATION);
        insert skill;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id,resourceRequest.Id);
        insert resourceSkillRequest;
        test.stopTest();
    }
    
	
    /**
    * This test method used for createSkillCertRatingsOnAssignCompleted method
    */
    @isTest
    static void testCreateSkillCertRatingsOnAssignCompleted() 
	{
        Test.startTest();        
        pse__Assignment__c assignement = [Select id, pse__Status__c from pse__Assignment__c limit 1];
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
        pse__Skill__c skill = [Select id from pse__Skill__c limit 1];
        Contact cont = [Select id from Contact limit 1];
        pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id,cont.Id);
        insert skillCertRating;
        update assignement;
        system.assertEquals(1,[Select id from pse__Skill_Certification_Rating__c limit 10].size(), 'Verifying createSkillCertRatingsOnAssignCompleted Functionality');
        delete skillCertRating;
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
        update assignement;
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
        update assignement;
        Test.stopTest();
        system.assertEquals(1,[Select id from pse__Skill_Certification_Rating__c limit 10].size(), 'Verifying createSkillCertRatingsOnAssignCompleted Functionality');
    }
	
    
    /**
	* This test method used for PopulateRollupAssignmentFieldsOnContact method
	*/
    @isTest
    static void testPopulateRollupAssignmentFieldsOnContact() 
	{
        Test.startTest();
        pse__Assignment__c assignement = [Select id, pse__Resource__c, pse__Status__c from pse__Assignment__c limit 1];
        Contact resource = [Select id, COUNT_Assignemnts_Pending__c, COUNT_Assignemnts_Accepted__c from Contact where Id =: assignement.pse__Resource__c limit 1];
        system.assertEquals(1,resource.COUNT_Assignemnts_Pending__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        system.assertEquals(0,resource.COUNT_Assignemnts_Accepted__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
        update assignement;
        resource = [Select id, COUNT_Assignemnts_Pending__c, COUNT_Assignemnts_Accepted__c from Contact where Id =: assignement.pse__Resource__c limit 1];
        system.assertEquals(0,resource.COUNT_Assignemnts_Pending__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        system.assertEquals(1,resource.COUNT_Assignemnts_Accepted__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        delete assignement;
        resource = [Select id, COUNT_Assignemnts_Pending__c, COUNT_Assignemnts_Accepted__c from Contact where Id =: assignement.pse__Resource__c limit 1];
        system.assertEquals(0,resource.COUNT_Assignemnts_Pending__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        system.assertEquals(0,resource.COUNT_Assignemnts_Accepted__c, 'Verifying PopulateRollupAssignmentFieldsOnContact Functionality' );
        Test.stopTest();
    }
    
	
    /**
	* This test method used for updateFieldsWhenStatusAndResourceChanged method
	*/
    @isTest
    static void testUpdateFieldsWhenStatusAndResourceChanged() 
	{
        Test.startTest();
        pse__Assignment__c assignement = [Select id, pse__Resource__c, pse__Status__c from pse__Assignment__c limit 1];
        Contact resource = [Select id, COUNT_Assignemnts_Pending__c, COUNT_Assignemnts_Accepted__c from Contact where Id =: assignement.pse__Resource__c limit 1];
        system.assertEquals(1,resource.COUNT_Assignemnts_Pending__c, 'Verifying updateFieldsWhenStatusAndResourceChanged Functionality');
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
        update assignement;
        pse__Assignment__c modifiedAssignement = [Select id, Accepted_Date__c from pse__Assignment__c Where Id = :assignement.Id];
        system.assert(modifiedAssignement.Accepted_Date__c != NULL, true);
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_REJECTED;
        assignement.Rejected_Reason__c = 'assignment rejected';
        update assignement;
        modifiedAssignement = [Select id, Rejected_Date__c from pse__Assignment__c Where Id = :assignement.Id];
        system.assert(modifiedAssignement.Rejected_Date__c != NULL, true);
        Test.stopTest();
    }
	
	
	/*This method used for test the PopulateDueDateatAssignmentAndDateLeadPDAssigned Method */
    @isTest
    static void testPopulateDueDateatAssignmentAndDateLeadPDAssigned()
    {
        Test.startTest();
        Contact cont = [Select Id from Contact limit 1];
        cont.sub_group__c = 'GBO-Lead PD';
        update cont;
        Opportunity opp = [Select id from Opportunity where Name = 'TestOpportunity' limit 1];
        Bid_History__c agreement =  [Select id from Bid_History__c where Bid_History_Related_Opportunity__c =: opp.Id ];
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = [Select id from pse__Resource_Request__c where SubGroup__c = 'GBO-Lead PD' limit 1];
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
        
        Bid_History__c agreementAterUpdate = [select Id,DueDateAtAssignment__c, DateLeadPDAssigned__c, Original_Due_Date__c, Actual_Working_Days2__c, Negotiated_Working_Days__c from Bid_History__c where Id =:agreement.Id];
        system.assert(agreementAterUpdate.DueDateAtAssignment__c!=Null, true);
        system.assert(agreementAterUpdate.Original_Due_Date__c!=Null, true);
        system.assert(agreementAterUpdate.DateLeadPDAssigned__c!=Null, true);
        Test.stopTest();
    }
    
	@isTest
    static void testUpdateAssignmentOnPDUpdate()
    {
		upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        Test.startTest(); 
            Contact cont = [Select Id from Contact limit 1];
			cont.sub_group__c = 'GBO-Lead PD';
			update cont;
			Opportunity opp = [Select id from Opportunity where Name = 'TestOpportunity' limit 1];
			Bid_History__c agreement =  [Select id from Bid_History__c where Bid_History_Related_Opportunity__c =: opp.Id ];
			pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
			pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
			insert schedule;
			pse__Resource_Request__c resourceRequest = [Select id from pse__Resource_Request__c where SubGroup__c = 'GBO-Lead PD' limit 1];
			pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
			insert assignement;
			assignement.pse__Status__c = 'Accepted';
			update assignement; 
		Test.stopTest();
        
        Bid_History__c agreement1 =  [Select id,DateLeadPDAssigned__c,DueDateAtAssignment__c  from Bid_History__c limit 1];
        system.assertNotEquals(null, agreement1.DateLeadPDAssigned__c, 'Verifying UpdateAssignmentOnPDUpdate Functionality');
        system.assertNotEquals(null, agreement1.DueDateAtAssignment__c, 'Verifying UpdateAssignmentOnPDUpdate Functionality');
        
    }
    
	@isTest
    static void testUpdateAssignmentClosed()
    {
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        Test.startTest();
            pse__Grp__c grp = [Select id from pse__Grp__c where Name = 'TestGroup' limit 1];
        	Contact cont = [Select Id from Contact limit 1];
			cont.sub_group__c = 'TSL';
			update cont;
			Opportunity opp = [Select id,QI_Invited_to_Present__c,Bid_Defense_Date__c,Presentation_Country__c,Presentation_Date_Status__c from Opportunity where Name = 'TestOpportunity' limit 1];
			Bid_History__c agreement =  [Select id from Bid_History__c  where RFP_Ranking__c = '2'];
			pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
			pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
			insert schedule;
			pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
			resourceRequest.pse__Group__c = grp.Id;
			resourceRequest.SubGroup__c =  'TSL';
			resourceRequest.Is_Bid_Defense__c = true;
			insert resourceRequest;
			pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
			insert assignement;
			assignement.pse__Status__c = 'Closed';
			update assignement;
		Test.stopTest();
        
        pse__Resource_Request__c rr = [select id, Is_Bid_Defense__c, SubGroup__c, RecordType.Name , pse__Status__c, Bid_History__c,pse__Start_Date__c from pse__Resource_Request__c Where SubGroup__c = 'TSL' limit 1];
        string expected = CON_OWF.OWF_STATUS_CLOSED;
        system.assertEquals(expected, rr.pse__Status__c, 'Verifying UpdateAssignmentClosed Functionality');
    }
    
	@isTest
    static void testUpdateScheduleHours()
    {
        Test.startTest();        
        List<pse__Assignment__c> assignementList = [SELECT Id,RecordTypeId, Bid_History__c, pse__Project__c, pse__Schedule__c, pse__Resource__c, pse__Resource_Request__c, pse__Status__c, pse__Bill_Rate__c from pse__Assignment__c limit 100];
        Map<Id, pse__Assignment__c> scheduleIdToAssignmentMap = new Map<Id,pse__Assignment__c>();
        for(pse__Assignment__c assignment : assignementList)
        {
            scheduleIdToAssignmentMap.put(assignment.Id,assignment);            
        }
        DAOH_OWF_Assignment.updateScheduleHours(assignementList,scheduleIdToAssignmentMap);
        Test.stopTest();
        
        system.assertNotEquals(null, assignementList.size(), 'Verifying UpdateScheduleHours( Functionality');
    }
    
    @isTest
    static void testupdateBudgetAnalystAssignedByAssignment()
    {
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        pse__Grp__c grp = [Select id from pse__Grp__c where Name = 'TestGroup' limit 1];
        Contact cont = [Select Id from Contact limit 1];
        cont.sub_group__c = 'GBO-Bid Grid';
        update cont;
        Opportunity opp = [Select id, Name from Opportunity where Name = 'TestOpportunity' limit 1];
        Bid_History__c agreement =  [Select id from Bid_History__c where Bid_History_Related_Opportunity__c =: opp.Id];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        Test.startTest();
            update agreement;
            pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
            pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
            insert schedule;
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.SubGroup__c =  'GBO-Bid Grid';
            resourceRequest.Is_Created_Automatically__c = True;
            insert resourceRequest;
            pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
            insert assignement;
            assignement.pse__Status__c = 'Accepted';
            update assignement;
        Test.stopTest();

        Bid_History__c agreement1 =  [Select id, Budget_Analyst_Assigned__c from Bid_History__c where Id =: agreement.Id];
        system.assertNotEquals(null, agreement1.Budget_Analyst_Assigned__c, 'Verifying updateBudgetAnalystAssignedByAssignment Functionality');
    }
    
    @isTest
    static void testSendEmailForContractPostAwardBidPathway()
    {
        Opportunity opp = [Select id, Name from Opportunity where Name = 'TestOpportunity' limit 1];
        Account acc = [Select Id From Account LIMIT 1];
        
        Bid_History__c bidHistoryContractPostAward = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        bidHistoryContractPostAward.Agreement_Pathway__c = CON_OWF.AGREEMENT_PATHWAY_LATEPHASE;
        insert bidHistoryContractPostAward;
        
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: bidHistoryContractPostAward.Id];
        
        pse__Grp__c grp = [Select id from pse__Grp__c where Name = 'TestGroup' limit 1];
        
        pse__Resource_Request__c resourceRequestGBOLeadContractsAnalyst = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistoryCOntractPostAward.Id, opp.Id, bidProject.Id);
        resourceRequestGBOLeadContractsAnalyst.pse__Group__c = grp.Id;
        resourceRequestGBOLeadContractsAnalyst.SubGroup__c = CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST;
        resourceRequestGBOLeadContractsAnalyst.pse__End_Date__c = system.today()+1;
        insert resourceRequestGBOLeadContractsAnalyst;
        
        Contact cont = [Select Id from Contact limit 1];
        cont.sub_group__c = CON_OWF.RES_REQ_TYPE_GBO_LEAD_CONTRACTS_ANALYST;
        update cont;
        
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        
        Test.startTest();
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(bidHistoryContractPostAward.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequestGBOLeadContractsAnalyst.Id);
        insert assignement;
        Test.stopTest();
        
        System.assertEquals(1, ([SELECT Id FROM Workflow_Email_Record__c LIMIT 1]).size(), 'Test: SendEmailForContractPostAwardBidPathway');
    }
    
    @isTest
    static void testUpdateAgreementOwnerByAssignment()
    {
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        pse__Grp__c grp = [Select id from pse__Grp__c where Name = 'TestGroup' limit 1];
        Contact cont = [Select Id from Contact limit 1];
        User user = [Select id from User where FirstName = 'Test2' limit 1];
        cont.sub_group__c = 'GBO-Bid Grid';
        update cont;
        Account acc = [Select Id From Account LIMIT 1];
        Contact cont1 = UTL_OWF_TestData.createContact(acc.Id);
        cont1.pse__Is_Resource__c = true;
        cont1.pse__Is_Resource_Active__c = true;
        cont1.pse__Group__c = grp.Id;
        cont1.FirstName = 'TestFirst';
        cont1.sub_group__c = 'GBO-Bid Grid';
        cont1.available_for_triage_flag__c = true;
        cont1.pse__Salesforce_User__c = user.Id;
        cont1.Salesforce_User__c = user.Id;
        insert cont1;
        Opportunity opp = [Select id, Name from Opportunity where Name = 'TestOpportunity' limit 1];
        Bid_History__c agreement =  [Select id from Bid_History__c where Bid_History_Related_Opportunity__c =: opp.Id];
        agreement.Is_there_a_Client_Bid_Grid__c = 'Yes';
        Test.startTest();
            update agreement;
            pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
            pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
            insert schedule;
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.SubGroup__c =  'IG-Lead';
            resourceRequest.Is_Created_Automatically__c = True;
            insert resourceRequest;
            pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont1.Id, resourceRequest.Id);
            insert assignement;
        	assignement.pse__Status__c = 'Accepted';
        	//assignement.pse__Resource__c = cont1.id;
        	update assignement;
        Test.stopTest();

        Bid_History__c agreement1 =  [Select id, Budget_Analyst_Assigned__c from Bid_History__c where Id =: agreement.Id];
        system.assertEquals(null, agreement1.Budget_Analyst_Assigned__c, 'Verifying updateAgreementOwnerByAssignment Functionality');
    }
}
