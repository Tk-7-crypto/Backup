/*
* Test class for FLOW- ASN_PB01_OWF_New_Pending_Assignment
*/
@IsTest
public class TST_ASN_PB01_OWF_New_Pending_Assignment {
    
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
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
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill',CON_OWF.SKILL_TYPE_INDICATION);
        insert skill;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id,resourceRequest.Id);
        insert resourceSkillRequest;
        test.stopTest();
    }
    
    @isTest
    static void testCreateAssignment()
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
        system.assert(agreementAterUpdate.Original_Due_Date__c!=Null, true);
        Test.stopTest();
    }
    
    @isTest
    static void testSetStatusOnProjectResReqsAndAssignments() 
    {
        Bid_History__c agreement = [SELECT Id, Bid_History_Account__c, Bid_History_Related_Opportunity__c FROM Bid_History__c limit 1];
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
        system.assertEquals(CON_OWF.OWF_STATUS_ASSIGNED, listOfRRs.get(0).pse__Status__c);
        
        List<pse__Assignment__c> listOfAssignments = [Select Id, pse__Status__c, pse__End_Date__c From pse__Assignment__c Where Bid_History__c = :agreement.Id];
        system.assertEquals(CON_OWF.OWF_STATUS_ACCEPTED, listOfAssignments.get(0).pse__Status__c);
        Test.stopTest();
    }
}