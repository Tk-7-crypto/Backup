@isTest
public class TST_BCH_OWF_UpdateSuggestedFTE {
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
        cont.sub_group__c = 'TSL';
        cont.available_for_triage_flag__c = true;
        cont.Secondary_Sub_Group__c = 'TSL-Japan';
        insert cont;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        User testUser = new User(Id = UserInfo.getUserId());
        testUser.SUBREGION__c = 'United States of America';
        testUser.EmployeeNumber = '87876567';
        update testUser;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Not Sure';
        opp.Line_of_Business__c = 'Clinical';
        opp.Bid_Defense_Date__c = system.today().addDays(3);
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Owner = testUser;
        opp.Is_this_IQVIA_Biotech__c = 'No';
        opp.InterventionType__c = 'Biosimilar';
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        agreement.Requested_Services__c = CON_OWF.REQUESTED_INTERNAL_SERVICES_FULL_SERVICE_FEASIBILITY;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        test.startTest();
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL';
        rrList.add(resourceRequest);
        insert rrList;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.id, bidProject.id, schedule.id, cont.id, resourceRequest.id);
        assignment.pse__Status__c = 'Accepted';
        assignmentList.add(assignment);
        insert assignmentList;
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'TSL',
            Sub_Group__c = 'TSL',
            Name = 'TSL'
        ));
        insert resourceToSubGroupSettingList;
        pse__Proj__c daysOffProject = UTL_OWF_TestData.createBidProject(grp.Id);
        daysOffProject.name = 'Annual Leave/Vacation';
        insert daysOffProject;
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateSuggestedFTE()
	{
        Test.startTest();
        pse__Skill__c skill = UTL_OWF_TestData.createSkills(CON_OWF.SKILL_NAME_STRATEGIC_ANALYTICS, CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY);
        insert skill;
        pse__Proj__c project = [Select id from pse__Proj__c Limit 1];
        Contact cont = [Select id, Sub_Group__c from Contact limit 1];
        cont.Sub_Group__c = 'TSL';
        update cont;
        Bid_History__c agreement = [Select Id From Bid_History__c limit 1];
        agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
        agreement.RFP_Ranking__c = '3';
        agreement.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
        update agreement;
        pse__Resource_Request__c resourceRequest = [Select Id, pse__Start_Date__c, pse__End_Date__c, Suggested_FTE__c, subGroup__c From pse__Resource_Request__c where subGroup__c = 'TSL' limit 1];
        resourceRequest.Is_Bid_Defense__c = true;
        resourceRequest.pse__Start_Date__c = system.today().addDays(-15);
        update resourceRequest;
        BCH_OWF_UpdateSuggestedFTE batch = new BCH_OWF_UpdateSuggestedFTE();
        database.executeBatch(batch, 1);
        Test.StopTest() ;
        system.assertEquals(2,[Select id, subGroup__c from pse__Resource_Request__c where subGroup__c = 'TSL'].size(),'testing of testUpdateSuggestedFTE');
    }
}
