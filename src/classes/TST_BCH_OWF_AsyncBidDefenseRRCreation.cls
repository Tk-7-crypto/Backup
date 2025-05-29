/*Test class of BCH_OWF_AsyncBidDefenseCreation*/


@isTest
public class TST_BCH_OWF_AsyncBidDefenseRRCreation {

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        if(psaList.size() == 0){
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        }
		List<User> userList = UTL_TestData.createUser('System Administrator', 2);
		userList[0].FirstName = 'TestRunner';
		userList[0].SUBREGION__c = 'United States of America';
		userList[0].IsActive = true;
		userList[1].FirstName = 'Test2';
		userList[1].SUBREGION__c = 'United States of America';
		userList[1].IsActive = true;
		insert userList;
		User testRunner = userList[0];
        System.runAs(testRunner) 
		{  
			Account acc = UTL_OWF_TestData.createAccount();
			insert acc;
			pse__Grp__c grp = UTL_OWF_TestData.createGroup();
			insert grp;
			Contact cont = UTL_OWF_TestData.createContact(acc.Id);
			cont.pse__Is_Resource__c = true;
			cont.pse__Is_Resource_Active__c = true;
			cont.pse__Group__c = grp.Id;
			cont.sub_group__c = 'TSL';
			cont.available_for_triage_flag__c = true;
			cont.pse__Salesforce_User__c = userInfo.getUserId();
			insert cont;
			pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
			insert permissionControlGroup;
			Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
			opp.Is_this_IQVIA_Biotech__c = 'Yes';
			opp.QI_Invited_to_Present__c = 'Yes';
			opp.Presentation_Date__c = system.today().addDays(10);
			opp.Bid_Defense_Date__c = system.today().addDays(5);
			opp.Presentation_Country__c = 'Armenia';
			opp.Presentation_Date_Status__c = 'Estimated';
			insert opp;
			Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        	agreement.Bid_Number__c = 0;
			agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
			agreement.RFP_Ranking__c = '2';
                agreement.Budget_Deliverable__c = CON_OWF.BUDGET_DELIVERABLE;
                agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
                agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
                agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
			insert agreement;
            Test.StartTest() ;
			pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
			pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
			resourceRequest.pse__Group__c = grp.Id;
			resourceRequest.SubGroup__c = 'TSL';
			resourceRequest.pse__Status__c = 'CON_OWF.OWF_STATUS_ASSIGNED';
			resourceRequest.Is_Bid_Defense__c = True;
			insert resourceRequest;
			pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
			insert schedule;
			pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
			insert assignment;
			TimeZone tz = UserInfo.getTimeZone();
			Timezone__c timezone = new Timezone__c(Batch_Name__c = 'BCH_OWF_UpdateResourceRequestStatus', Module__c = 'OWF');
			timezone.Offset__c = (tz.getOffset(DateTime.now()))/3600000.0;
			timezone.Name = tz.getID();
			timezone.CutOffUTCTime__c = System.now().addHours(-1);
			insert timezone;												 
            Test.StopTest() ;

        }
    }
    
    /**
    * This test method used to test BCH_OWF_AcceptUnassignedAssignments batch class.
    */
    @isTest
    public static void testAcceptUnassignedAssignments()
	{
        pse__Assignment__c assignment = [Select Id, pse__Status__c from pse__Assignment__c limit 1];
        Test.StartTest() ;
            BCH_OWF_AcceptUnassignedAssignments batch = new BCH_OWF_AcceptUnassignedAssignments();
            database.executeBatch(batch, 10); 
        BCH_OWF_AsyncBidDefenseRRCreation bt = new BCH_OWF_AsyncBidDefenseRRCreation(new List<Id>{assignment.Id},CON_OWF.BCH_ACCEPTING_MODE);
        database.executeBatch(bt, 10);
        Test.StopTest() ;
        system.assertEquals(1,[Select id from pse__Assignment__c where pse__Status__c = 'Accepted'].size(), 'Verifying BCH_OWF_AsyncBidDefenseRRCreation Functionality');
    }
    
    /**
    * This test method used to test BCH_OWF_AcceptUnassignedAssignments batch class.
    */ 
    @isTest
    public static void testNegativeAcceptUnassignedAssignments()
	{
        pse__Assignment__c assignment = [Select Id, pse__Status__c from pse__Assignment__c limit 1];
        Test.setCreatedDate(assignment.Id, System.today().addDays(-3));
        Test.StartTest() ;
            pse__Assignment__History assignmentHistory = new pse__Assignment__History();
            assignmentHistory.ParentId = assignment.Id;
            assignmentHistory.Field = CON_OWF.ASSIGNMENT_STATUS;
            insert assignmentHistory;
            BCH_OWF_AcceptUnassignedAssignments batch = new BCH_OWF_AcceptUnassignedAssignments();
            database.executeBatch(batch, 10);       
        BCH_OWF_AsyncBidDefenseRRCreation bt = new BCH_OWF_AsyncBidDefenseRRCreation(new List<Id>{assignment.Id},CON_OWF.BCH_ACCEPTING_MODE);
        database.executeBatch(bt, 10);
        Test.StopTest() ;
		
        system.assertEquals(0,[Select id from pse__Assignment__c where pse__Status__c = 'Accepted'].size(), 'Verifying BCH_OWF_AsyncBidDefenseRRCreation Functionality');
    }
    
    
    /**
	* This test method used to test BCH_OWF_UpdateAssignmentsStatus batch class.
	*/
    @isTest
	public static void testUpdateCompletedStatusOnAssignment()
	{
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{
            Test.StartTest() ;
				List<pse__Resource_Request__c> rr = [select id, Is_Bid_Defense__c, SubGroup__c,pse__Opportunity__c, RecordType.Name , pse__Status__c, Bid_History__c,  pse__Start_Date__c from pse__Resource_Request__c limit 100];
				pse__Assignment__c assignment = [Select Id, pse__Status__c, Subgroup_Name__c, pse__Resource_Request__c  from pse__Assignment__c where pse__Resource_Request__c =: rr];
				assignment.pse__Status__c = 'Accepted';
				update assignment;
				Opportunity opp = [select id, Name, Bid_Defense_Date__c from Opportunity limit 10];
				opp.Bid_Defense_Date__c = system.today().addDays(-5);
				update opp;
				List<Timezone__c> timeZoneList = UTL_OWF.fetchTimezone('OWF','BCH_OWF_UpdateResourceRequestStatus');
				Map<String,List<String>> eligibleTimeZones = UTL_OWF.createTimezoneMap(timeZoneList);
				BCH_OWF_UpdateAssignmentsStatus batch = new BCH_OWF_UpdateAssignmentsStatus(eligibleTimeZones, timeZoneList);
				database.executeBatch(batch, 10);      
			Test.StopTest() ;
        
            List<pse__Assignment__c> modifiedAssignment = [Select Id, pse__Status__c From pse__Assignment__c limit 1];
			system.assertEquals(CON_OWF.OWF_STATUS_COMPLETED, modifiedAssignment.get(0).pse__Status__c, 'Verifying BCH_OWF_UpdateAssignmentsStatus Functionality');
		}
    }
    
}
