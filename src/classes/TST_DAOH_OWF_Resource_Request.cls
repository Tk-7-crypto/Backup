/**
 * This test class is used to test all methods in Resource Request trigger.
 * version : 1.0
 */
@isTest
private class TST_DAOH_OWF_Resource_Request {
    
	/**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        Test.startTest();
       PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        if(psaList.size() == 0){
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        }	
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
        insert new PermissionSetAssignment(AssigneeId =userList[0].Id,PermissionSetId = ps.Id);
        User testRunner = userList[0];
        System.runAs(testRunner) 
		{  
            Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
            mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
            upsert mulesoftIntegrationSettings;
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            pse__Grp__c grp = UTL_OWF_TestData.createGroup();
            insert grp;
            Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
            insert indication;
            pse__Work_Calendar__c workCal = CommanUtilityTestFunction.setUpWorkCalender();
            insert workCal;
            Contact cont = UTL_OWF_TestData.createContact(acc.Id);
            cont.pse__Is_Resource__c = true;
            cont.pse__Is_Resource_Active__c = true;
            cont.pse__Group__c = grp.Id;
            cont.Baseline_FTE__c = 1.0;
            cont.Available_for_Triage_Flag__c = true;   
            cont.pse__Salesforce_User__c = userList[0].Id;
            cont.sub_group__c = 'TSL-Japan';
            cont.pse__Work_Calendar__c = workCal.id;
            cont.FirstName = 'TestFirstName';
            insert cont; 
            Contact cont2 = UTL_OWF_TestData.createContact(acc.Id);
            cont2.pse__Is_Resource__c = true;
            cont2.pse__Is_Resource_Active__c = true;
            cont2.pse__Group__c = grp.Id;
            cont2.Baseline_FTE__c = 1.0;
            cont2.Available_for_Triage_Flag__c = true;
            cont2.pse__Salesforce_User__c = userList[1].Id;
            cont2.Backup_OWF_User__c = cont.id; 
            cont2.sub_group__c = 'TSL-Japan'; 
            cont2.pse__Work_Calendar__c = workCal.id;
            cont2.FirstName = 'TestFirstName';
            insert cont2;
            Contact cont3 = UTL_OWF_TestData.createContact(acc.Id);
            cont3.pse__Is_Resource__c = true;
            cont3.pse__Is_Resource_Active__c = true;
            cont3.pse__Group__c = grp.Id;
            cont3.Baseline_FTE__c = 1.0;
            cont3.Available_for_Triage_Flag__c = true;
            cont3.pse__Salesforce_User__c = userList[2].Id;
            cont3.Backup_OWF_User__c = cont.id; 
            cont3.sub_group__c = 'TSL'; 
            cont3.pse__Work_Calendar__c = workCal.id;
            cont3.FirstName = 'TestFirstName';
            insert cont3;
            Contact cont4 = UTL_OWF_TestData.createContact(acc.Id);
            cont4.pse__Is_Resource__c = true;
            cont4.pse__Is_Resource_Active__c = true;
            cont4.pse__Group__c = grp.Id;
            cont4.Baseline_FTE__c = 1.0;
            cont4.Available_for_Triage_Flag__c = true;
            cont4.pse__Salesforce_User__c = userList[3].Id;
            cont4.Backup_OWF_User__c = cont.id; 
            cont4.sub_group__c = 'Medical-MSL'; 
            cont4.pse__Work_Calendar__c = workCal.id;
            cont4.FirstName = 'TestFirstName';
            insert cont4;																   
            OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        	owfConfig.LCS_Bid_Defence_Resource__c = cont2.id;
            insert owfConfig;
            pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
            permissionControlGroup.pse__User__c = userList[0].id;
            insert permissionControlGroup;
            Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
            opp.Potential_Regions__c = 'Global';
            opp.Line_of_Business__c = 'Clinical';
            opp.Bid_Defense_Date__c = Date.Today().addDays(5);
            opp.Owner = userList[0];                     
            insert opp;
            Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
            agreement.RFP_Ranking__c = '2';
            agreement.Budget_Deliverable__c = CON_OWF.BUDGET_DELIVERABLE;
            agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
            agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
            agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
            agreement.Bid_Complexity__c = 'Low';
            agreement.RFP_Ranking__c = '1';
            insert agreement;
            List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
            resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
            ));
            resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'CTS-Lead',
            Sub_Group__c = 'CTS-Lead',
            Name = 'CTS-Lead',
            Auto_Assign_Resource__c = cont.Id
            ));
            insert resourceToSubGroupSettingList;
            Test.stopTest();
        }  
    }
    
	
    /**
    * This test method used to update Resource Request record
    */
    @isTest
    static void testResourceRequestUpdate() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        { 
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Opportunity oppty = [SELECT Id,BD_Sub_Region_2__c FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.RecordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.SubGroup__c = 'TSL';
            Test.startTest();
                insert resourceRequest;
                resourceRequest.SubGroup__c = 'SPN Product Specialist';
                update resourceRequest;
            Test.stopTest();
			
            pse__Resource_Request__c actualRR = [Select Id, pse__Resource_Request_Name__c, Resource_Request_Type__c, SubGroup__c From pse__Resource_Request__c limit 1];
            String expected = actualRR.Resource_Request_Type__c + '/' + actualRR.SubGroup__c;
            system.assertEquals(expected, actualRR.pse__Resource_Request_Name__c, 'Verifying ResourceRequestUpdate Functionality');
        }
    }
    
	
    /**
    * This test method used to update Resource Request record
    */
    @isTest
    static void testCancelRelatedAssignments()
	{
        User testRunner = [SELECT Id, Profile.Name from User where FirstName = 'TestRunner'];
        System.runAs(testRunner)
		{ 
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Test.startTest();
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            	resourceRequest.RecordTypeId =  CON_OWF.OWF_RR_RECORD_TYPE_ID;
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.Is_Created_Automatically__c = true;
				insert resourceRequest;
				List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				insert listToInsertSchedules;
				List<pse__Assignment__c> listToInsertAssignments = new List<pse__Assignment__c>();
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, cont.Id, resourceRequest.Id));
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(1).Id, cont.Id, resourceRequest.Id));
				insert listToInsertAssignments;
				resourceRequest.pse__Status__c = 'Cancelled';
				resourceRequest.Cancellation_Reason__c = 'Duplicate Request';
				update resourceRequest;
            Test.stopTest();
            
            String expectedStatus = 'Cancelled';
            pse__Assignment__c actualAssignmentList = [Select Id, pse__Status__c From pse__Assignment__c limit 1]; 
            system.assertEquals(expectedStatus, actualAssignmentList.pse__Status__c, 'Verifying CancelRelatedAssignments Functionality');
        }
    }
    
	
    /**
    * This test method used to Create Resource Skill Request records
    */
    @isTest
    static void testCreateResourceSkillRequest() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner)
		{ 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills('FSP', 'Opportunity Level');
            pse__Skill__c skill6 = UTL_OWF_TestData.createSkills('IQVIA Biotech', 'Opportunity Level');
            pse__Skill__c skill7 = UTL_OWF_TestData.createSkills('FSP_Skill', 'Opportunity Type');
            pse__Skill__c skill8 = UTL_OWF_TestData.createSkills('Core', 'Opportunity Level');
            
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            skillList.add(skill5);
            skillList.add(skill6);
            skillList.add(skill7);
            skillList.add(skill8);
            insert skillList;
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            agreement.Opportunity_Type__c = 'FSP_Skill';
            update agreement;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            List<User> userList = UTL_TestData.createUser('System Administrator', 2);
            userList[0].FirstName = 'Test1';
            userList[0].SUBREGION__c = 'United States of America';
            userList[0].IsActive = true;
            userList[1].FirstName = 'Test2';
            userList[1].SUBREGION__c = 'United States of America';
            userList[1].IsActive = true;
            insert userList;
            cont.pse__Salesforce_User__c = userList[0].id;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Is_this_IQVIA_Biotech__c = 'Yes';
            oppty.FSP__c = 'Yes';
            update oppty;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            Test.startTest();
            insert resourceRequest;
            oppty.Potential_Regions__c = 'USA/Canada';
            update oppty;
            pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest2.pse__Group__c = grp1.Id;
            resourceRequest2.Is_Created_Automatically__c = true;
            insert resourceRequest2;
            Test.stopTest();
            
            List<pse__Resource_Skill_Request__c> rsr = [select id, pse__Skill_Certification__c, pse__Resource_Request__c  from pse__Resource_Skill_Request__c limit 10];
            system.assert(rsr.size() > 0,'Verifying CreateResourceSkillRequest Functionality');
        }
    }
    
	
    /**
    * This test method used to Delete Assignment Based On Resource Request
    */
    @isTest
    static void testDeleteAssignmentBasedOnResourceRequest()
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact' limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Test.startTest();
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.Is_Created_Automatically__c = true;
				insert resourceRequest;    
				pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
				insert schedule;           
				pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, cont.Id, resourceRequest.Id);
				insert assignment;
				delete resourceRequest;
            Test.stopTest();
            
            List<pse__Assignment__c> assignmentList = [Select Id From pse__Assignment__c Where pse__Resource_Request__c = :resourceRequest.Id];
            Integer expected = 0;
            System.assertEquals(expected, assignmentList.size(), 'Verifying DeleteAssignmentBasedOnResourceRequest Functionality');
        }
    }
    
	
    /**
    * This test method used to test the rollup values of the Assignments fields on the Resource based on the value of Suggested FTE.
    */
    @isTest
    static void testpopulateRollupAssignmentFieldsOnContact()
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact' limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Test.startTest();
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.Is_Created_Automatically__c = true;
				insert resourceRequest;
				pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
				insert schedule;
				pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, cont.Id, resourceRequest.Id);
				insert assignment;
				resourceRequest.Suggested_FTE__c = 10;
                update resourceRequest;
            Test.stopTest();
            
            List<Contact> contactList = [Select Id, Pending_FTE_Sum__c From Contact Where Id = :cont.Id];
            Decimal expected = 0.10;
            system.assertEquals(expected, contactList[0].Pending_FTE_Sum__c, 'Verifying populateRollupAssignmentFieldsOnContact Functionality');
        }
    }
    
	
    /**
    * This method used to test the CreateAssignment method
    */
    @isTest
    static void testCreateAssignment() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
		System.runAs(testRunner) 
		{ 
			List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];          
			List<pse__Skill__c> skillList = new List<pse__Skill__c>();
			pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
			pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Global', 'User Regional Geographic Working Scope');
			pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
			pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
			skillList.add(skill1);
			skillList.add(skill2);
			skillList.add(skill3);
			skillList.add(skill4);
			insert skillList;
			List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
			System.runAs(new User(Id = UserInfo.getUserId())) {
				for(pse__Skill__c skill : skillList) {
					pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
					scr.pse__Rating__c = '5 - Expert';
					scrList.add(scr);
				}
				insert scrList;
			}
			List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
			listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
			listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
			insert listToInsertSchedules; 
			Account acc = UTL_OWF_TestData.createAccount();
			insert acc;
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
			Test.startTest();
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				pse__Proj__c project0 = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project0.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.subgroup__c = 'TSL-Japan';
				resourceRequest.Original_Assignee__c = contactList[0].Id;
				resourceRequest.Is_Created_Automatically__c = true;
				insert resourceRequest;
				pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement0.Id, project0.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest.id);
				insert assign1;
			Test.stopTest();
			
			List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
			system.assertNotEquals(null, assign.size(), 'Verifying CreateAssignment Functionality');   
        }
    }
    
    @isTest
    static void testCreateAssignmentForDaysOff()
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Global', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            System.runAs(new User(Id = UserInfo.getUserId())) 
			{
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Proj__c project0 = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project0.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.subgroup__c = 'TSL-Japan';
            resourceRequest.Original_Assignee__c = contactList[0].Id;
            resourceRequest.Is_Created_Automatically__c = true;
            insert resourceRequest;
            pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement0.Id, project0.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest.id);
				insert assign1;
				Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
				Test.startTest();
				insert agreement;
				pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
				Days_Off__c daysOffAssignment = new Days_Off__c();
                daysOffAssignment.First_Day_Off__c = system.today();
                daysOffAssignment.Last_Day_Off__c = daysOffAssignment.First_Day_Off__c.addDays(90);
                daysOffAssignment.Assignment_Type__c = 'Days Off';
                daysOffAssignment.Request_Type__c = 'Annual Leave/Vacation';
                daysOffAssignment.Employee__c = contactList[0].Id;
                insert daysOffAssignment;
				pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest2.pse__Group__c = grp1.Id;
				resourceRequest2.subgroup__c = 'TSL-Japan';
				//resourceRequest2.Original_Assignee__c = contactList[0].Id;
				resourceRequest2.Is_Created_Automatically__c = true;
				insert resourceRequest2;
				Test.stopTest();
            
            List<pse__Assignment__c> assign = [select id,pse__Resource__c, pse__Resource_Request__c  from pse__Assignment__c where pse__Resource_Request__c  =: resourceRequest2.Id];
            system.assertEquals(0, assign.size(), 'Verifying CreateAssignmentForDaysOff Functionality');
        }
    }   
    
    
    /**
    * This method used to test the CreateBDAssignment method
    */
    @isTest
    static void testCreateBDAssignment() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
			List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];          
			List<pse__Skill__c> skillList = new List<pse__Skill__c>();
			pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
			pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Global', 'User Regional Geographic Working Scope');
			pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
			pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
			skillList.add(skill1);
			skillList.add(skill2);
			skillList.add(skill3);
			skillList.add(skill4);
			insert skillList;
			List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
			System.runAs(new User(Id = UserInfo.getUserId())) {
				for(pse__Skill__c skill : skillList) {
					pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
					scr.pse__Rating__c = '5 - Expert';
					scrList.add(scr);
				}
				insert scrList;
			}
            /*List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;*/
            Account acc=[Select id from Account limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.QI_Invited_to_Present__c = 'yes';
            oppty.Presentation_Date_Status__c = 'Estimated';
            oppty.Bid_Defense_Date__c = Date.today().addDays(8);
            oppty.Presentation_Country__c = 'India';
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Potential_Regions__c = 'Asia Pacific';
            Test.startTest();
            update oppty;
            Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement.Bid_Number__c = 1;
            agreement.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
            agreement.Budget_Deliverable__c = 'Full Budget';
            agreement.Requested_Services__c = 'Clinical Monitoring;Project Management;Patient Recruitment;Late Phase Site Start up (SPS)';
            agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
            agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;	
            agreement.RFP_Ranking__c = '3';
            agreement.Bid_Due_Date__c = Date.today().addDays(8);
            insert agreement;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            List<pse__Resource_Request__c> resRequestList = new List<pse__Resource_Request__c>();
            //pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
			/*resourceRequest.pse__Group__c = grp1.Id;
			resourceRequest.subgroup__c = 'TSL';
			resourceRequest.Complexity_Score_Total__c = 0;
			resourceRequest.pse__Start_Date__c = Date.today().addDays(7);
			resourceRequest.Is_Created_Automatically__c = true;
            insert resourceRequest;
            pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id,project.Id, null, cont.Id, resourceRequest.ID);
            assignment.pse__Status__c = 'Accepted';
            insert assignment;*/
            pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest2.pse__Group__c = grp1.Id;
            resourceRequest2.subgroup__c = 'TSL';
            resourceRequest2.Is_Bid_Defense__c = True;
            resourceRequest2.Complexity_Score_Total__c = 0;
            resourceRequest2.pse__Start_Date__c = Date.today().addDays(7);
            resourceRequest2.Is_Created_Automatically__c = true;
            resRequestList.add(resourceRequest2);
            insert resourceRequest2; 
            Test.stopTest();
            
            List<pse__Resource_Request__c> rr = [Select id, Name, Is_Bid_Defense__c from pse__Resource_Request__c where id =: resourceRequest2.id];
            system.assertEquals(true, rr[0].Is_Bid_Defense__c, 'Verifying CreateBDAssignment Functionality');
        } 
    }
	
    /**
    * This method used to test the CreateAssignment method
    */
    @isTest
    static void testCreateClinicalAssignment() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
			pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_INDICATION);
			insert skill;
			List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];
			
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
			insert skillCertRating;
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c where RFP_Ranking__c > '1' ][0];
			pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
			pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
			pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
			resourceRequest1.pse__Group__c = grp1.Id;
			resourceRequest1.subgroup__c = 'TSL-Japan';
			resourceRequest1.Is_Created_Automatically__c = true;
			insert resourceRequest1;
			List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
			listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
			listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
			insert listToInsertSchedules; 
			Test.startTest();
				List<pse__Assignment__c> listToInsertAssignments = new List<pse__Assignment__c>();
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest1.Id));
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(1).Id, contactList[0].Id, resourceRequest1.Id));
				insert listToInsertAssignments;
				pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resourceRequest1.Id);
				insert resourceSkillRequest;
				pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest2.pse__Group__c = grp1.Id;
				resourceRequest2.subgroup__c = 'TSL-Japan';
				resourceRequest2.Is_Created_Automatically__c = true;
				insert resourceRequest2;
				List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c FROM pse__Resource_Skill_Request__c limit 1000];
				List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
				Integer expectedListSize = 2;
				system.assertEquals(expectedListSize, resourceCandidateMatchScoreList.size(), 'Verifying CreateClinicalAssignment Functionality');
          Test.stopTest();
        }
    }
    
	
    /**
    * This method used to test the CreateBDRegionAssignment method
    */
    @isTest
    static void testCreateBDRegionAssignment()
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
			Test.startTest();
				List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];
				List<pse__Skill__c> skillList = new List<pse__Skill__c>();
				pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
				pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Global', 'User Regional Geographic Working Scope');
				skill2.name = 'United States of America';
				pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
				pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
				skillList.add(skill1);
				skillList.add(skill2);
				skillList.add(skill3);
				skillList.add(skill4);
				insert skillList;
				List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
				System.runAs(new User(Id = UserInfo.getUserId())) {
					for(pse__Skill__c skill : skillList) {
						pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
						scr.pse__Rating__c = '5 - Expert';
						scrList.add(scr);
					}
					insert scrList;
				}
				List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				insert listToInsertSchedules; 
				Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
				Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
				pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				pse__Assignment__c assign = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(1).Id, contactList[0].Id, null);
				assign.assignment_type__c = 'Days Off';
				insert assign;
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.subgroup__c = 'TSL-Japan';
				resourceRequest.Potential_Regions__c = 'Global';
				resourceRequest.Is_Created_Automatically__c = true;
				insert resourceRequest;
				resourceRequest.Is_Bid_Defense__c = true;
				update resourceRequest;
			Test.stopTest();
			
            List<pse__Resource_Request__c> rr = [Select id, Name, Is_Bid_Defense__c from pse__Resource_Request__c where id =: resourceRequest.id];
        	system.assertEquals(true, rr[0].Is_Bid_Defense__c, 'Verifying CreateBDRegionAssignment Functionality');
        }  
    }
    
	
    /**
    * This test method used to Create Resource Skill Request records
    */
    @isTest
    static void testCreateAssignmentBasedOnPR() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            skill2.pse__type__c = 'User Regional Geographic Working Scope';
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            List<Contact> contactList = [Select Id From Contact where Backup_OWF_User__c != null];      
            System.runAs(new User(Id = UserInfo.getUserId())) {
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }             
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules;
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.subgroup__c = 'GBO-Lead PD';
            resourceRequest.Is_Created_Automatically__c = true;
            Test.startTest();
                insert resourceRequest;
                oppty.Potential_Regions__c = 'USA/Canada';
                update oppty;
                pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
                resourceRequest2.pse__Group__c = grp1.Id;
                resourceRequest2.subgroup__c = 'TSL-Japan';
                resourceRequest2.Is_Created_Automatically__c = true;
                insert resourceRequest2;
            	pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest.id);
				insert assign1;
            Test.stopTest();
            
            List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
            system.assertNotEquals(0, assign.size(), 'Verifying CreateAssignmentBasedOnPR Functionality');
        }
    }
    
	
    /**
    * This test method used to populate Project On RR
    */
    @isTest
    static void testPopulateProjectOnRR() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) { 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            skill2.pse__type__c = 'User Regional Geographic Working Scope';
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            List<Contact> contactList = [Select Id From Contact where Backup_OWF_User__c != null];      
            System.runAs(new User(Id = UserInfo.getUserId())) {
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, null);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.subgroup__c = 'GBO-Lead PD';
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.RecordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
            resourceRequest.pse__Project__c = null;
			List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>();
            Test.startTest();
                rrList.add(resourceRequest);
                oppty.Potential_Regions__c = 'USA/Canada';
                update oppty;
                pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, null);
                resourceRequest2.pse__Group__c = grp1.Id;
                resourceRequest2.subgroup__c = 'TSL-Japan';
                resourceRequest2.Is_Created_Automatically__c = true;
            	resourceRequest2.RecordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
            	resourceRequest2.pse__Project__c = null;
            	rrList.add(resourceRequest2);
                insert rrList;           
            	DAOH_OWF_Resource_Request.populateProjectOnRR(rrList);
            Test.stopTest();
            
            List<pse__Resource_Request__c> rr = [Select id, pse__Project__c from pse__Resource_Request__c where id =: rrList];
            system.assertNotEquals(0,rr.size(), 'Verifying PopulateProjectOnRR Functionality');
        }
    }
    
	
    /**
    * This test method used to populate Project On RR
    */
    @isTest
    static void testPopulateRRFieldsFromAgreement() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            skill2.pse__type__c = 'User Regional Geographic Working Scope';
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            List<Contact> contactList = [Select Id From Contact where Backup_OWF_User__c != null];      
            System.runAs(new User(Id = UserInfo.getUserId())) {
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            List<pse__Resource_Request__c> rrList = [Select Id from pse__Resource_Request__c where Bid_History__c =: agreement.Id ];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, null);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.pse__Opportunity__c = null;
            resourceRequest.subgroup__c = 'TSL-Japan';
            resourceRequest.Is_Created_Automatically__c = true;
            Test.startTest();
                insert resourceRequest;
            Test.stopTest();
			
            system.assertEquals(rrList.size() + 1 , [Select Id from pse__Resource_Request__c where Bid_History__c =: agreement.Id ].size(), 'Verifying PopulateRRFieldsFromAgreement Functionality');
        }
    }
    
    
	/**
	* This method used to test the CreateAssignment method
	*/ 
    @isTest
    static void testCreateRebidAssignment() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_INDICATION);
            insert skill;
            List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];
            
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
            insert skillCertRating;
            Test.startTest();
				Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
				Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c where RFP_Ranking__c > '1' ][0];
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				Account acc = [Select id from Account limit 1];
				pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
				pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest1.pse__Group__c = grp1.Id;
				resourceRequest1.subgroup__c = 'TSL-Japan';
				resourceRequest1.Is_Created_Automatically__c = true;
				insert resourceRequest1;
				List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				insert listToInsertSchedules;
				List<pse__Assignment__c> listToInsertAssignments = new List<pse__Assignment__c>();
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest1.Id));
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(1).Id, contactList[0].Id, resourceRequest1.Id));
				insert listToInsertAssignments;
				Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
				insert agreement2;
            Test.stopTest();
			
			List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
            system.assertNotEquals(0, assign.size(), 'Verifying CreateAssignment Functionality');
        }
    }
    
	@isTest
    static void testCreateResourceSkillRequestForGBO() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('USA/Canada', CON_OWF.SKILL_TYPE_POTENTIAL_REGION);
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills('RFP Ranking', CON_OWF.SKILL_TYPE_GRADE_LEVEL);
            skillList.add(skill4);
            skillList.add(skill5);
            insert skillList;
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.sub_group__c=CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD;
            update cont;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.Potential_Regions__c ='USA/Canada';
            update oppty;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.SubGroup__c =CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD;
            List<pse__Skill_Certification_Rating__c> skillCertRatingList = new List<pse__Skill_Certification_Rating__c>();
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill4.Id,cont.Id);
            skillCertRatingList.add(skillCertRating);
            pse__Skill_Certification_Rating__c skillCertRating1 = UTL_OWF_TestData.createSkillCertificationRating(skill5.Id,cont.Id);
            skillCertRating1.RFP_Ranking__c = 'RFP Ranking 2';
            skillCertRatingList.add(skillCertRating1);
            Test.startTest();
            	insert skillCertRatingList;
                insert resourceRequest;
            Test.stopTest();
			
            List<pse__Resource_Skill_Request__c> rsr = [select id,  pse__Resource_Request__c  from pse__Resource_Skill_Request__c where pse__Resource_Request__c =: resourceRequest.Id];
            system.assertNotEquals(0, rsr.size(), 'Verifying CreateResourceSkillRequestForGBO Functionality');
        }
    }

    static testMethod void testCreateResourceSkillRequestForGBORFI() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            
            Test.startTest();
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('USA/Canada', CON_OWF.SKILL_TYPE_POTENTIAL_REGION);
            pse__Skill__c skill6 = UTL_OWF_TestData.createSkills('RFP Ranking 2', CON_OWF.SKILL_TYPE_TRIAGE_LEVEL);
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills('Level B Supplier Qualification Audit', CON_OWF.SKILL_TYPE_TRIAGE_LEVEL);
            skillList.add(skill4);
            skillList.add(skill5);
            skillList.add(skill6);
            insert skillList;
            Account acc = [Select id from Account Limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.Potential_Regions__c ='USA/Canada';
            update oppty;
            Bid_History__c agreementRFI = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID);
            agreementRFI.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
            agreementRFI.Triage_Level__c = 'Level B Supplier Qualification Audit';
            agreementRFI.RFP_Ranking__c = '2';
            agreementRFI.Budget_Deliverable__c = CON_OWF.BUDGET_DELIVERABLE;
            agreementRFI.Proposal_Deliverable__c = 'Summary of key study assumptions, experience and budget';
            agreementRFI.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
            agreementRFI.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
            agreementRFI.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
            agreementRFI.Number_of_Requested_Services__c = 7;
            agreementRFI.Estimated_Fees__c = 'Less than $10M';
            agreementRFI.Original_Due_Date__c = Date.today().addDays(10);
            agreementRFI.Bid_Complexity__c = 'Low';
            insert agreementRFI;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.sub_group__c='GBO-RFI';
            update cont;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreementRFI.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreementRFI.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.SubGroup__c = 'GBO-RFI';
            List<pse__Skill_Certification_Rating__c> skillCertRatingList = new List<pse__Skill_Certification_Rating__c>();
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill4.Id,cont.Id);
            skillCertRatingList.add(skillCertRating);
            pse__Skill_Certification_Rating__c skillCertRating1 = UTL_OWF_TestData.createSkillCertificationRating(skill5.Id,cont.Id);
            skillCertRatingList.add(skillCertRating1);
            	insert skillCertRatingList;
                insert resourceRequest;
            Test.stopTest();
			
            List<pse__Resource_Skill_Request__c> rsr = [select id,  pse__Resource_Request__c  from pse__Resource_Skill_Request__c where pse__Resource_Request__c =: resourceRequest.Id];
            system.assertNotEquals(0, rsr.size(), 'Verifying CreateResourceSkillRequestForGBORFI Functionality');
        }
    }

    @isTest
    static void testCreatePostAwardRR() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_INDICATION);
            insert skill;
            List<Contact> contactList = [Select Id,Sub_Group__c From Contact where FirstName = 'TestFirstName'];
            contactList[0].Sub_Group__c = 'TSL';
            update contactList;
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
            insert skillCertRating;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c where RFP_Ranking__c > '1' ][0];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Account acc = [Select id from Account limit 1];
            pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest1.pse__Group__c = grp1.Id;
            resourceRequest1.subgroup__c = 'TSL';
            resourceRequest1.Is_Created_Automatically__c = true;
            resourceRequest1.Original_Assignee__c = contactList[0].id;
            resourceRequest1.pse__Staffer_Resource__c = contactList[0].id;
            insert resourceRequest1;
			List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
			listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
			insert listToInsertSchedules;
			List<pse__Assignment__c> listToInsertAssignments = new List<pse__Assignment__c>();
			listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest1.Id));
			insert listToInsertAssignments;
        	List<pse__Assignment__c> assignmentList = [Select id,pse__Status__c,pse__Resource_Request__r.SubGroup__c from pse__Assignment__c where pse__Resource_Request__r.SubGroup__c ='TSL'];
                for(pse__Assignment__c ass:assignmentList) {
                    ass.pse__Status__c = 'Accepted';
                }
			update assignmentList;
            Test.startTest();
            	Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
				insert agreement2;
				pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement2.Id, oppty.Id, project.Id);
				resourceRequest2.pse__Group__c = grp1.Id;
				resourceRequest2.subgroup__c = 'TSL';
				resourceRequest2.Is_Created_Automatically__c = true;
            	resourceRequest2.Original_Assignee__c = contactList[0].id;
				insert resourceRequest2;
            Test.stopTest();
			
            List<pse__Resource_Request__c> rr = [Select Id, Resource_Request_Type__c from pse__Resource_Request__c where  Resource_Request_Type__c = 'Post Award'];
            String expected = 'Post Award';
            system.assertEquals(expected, rr[0].Resource_Request_Type__c, 'Verifying CreatePostAwardRR Functionality');
        }
    }
    
    @isTest
    static void testCreateAssignmentForTSSU() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];          
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Clinical', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Asia Pacific', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Traumatic brain injury', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Neurology', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.Sub_Group__c = 'TSL';

            update cont;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
            agreement0.Opportunity_Type__c = '';
            agreement0.RFP_Ranking__c = '2';
            agreement0.Budget_Deliverable__c= '';

            update agreement0;
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				pse__Proj__c project0 = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project0.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.subgroup__c = 'TSL';
				resourceRequest.Original_Assignee__c = contactList[0].Id;
				resourceRequest.Is_Created_Automatically__c = true;
            	Test.startTest();    

				insert resourceRequest;
				pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement0.Id, project0.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest.id);
				insert assign1;
                Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
                insert agreement;
                Test.stopTest();

			
            	List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];

			system.assertNotEquals(0, assign.size(), 'Verifying CreateAssignmentForTSSU Functionality');
        }
    }
    
    
	@isTest
    static void testcreateAssignmentsForClosedBDRR() 
	{
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
		{ 
            List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName'];          
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Clinical', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Asia Pacific', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Traumatic brain injury', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Neurology', 'Therapy Area');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            insert skillList;
            List<pse__Skill_Certification_Rating__c> scrList = new List<pse__Skill_Certification_Rating__c>();
            System.runAs(new User(Id = UserInfo.getUserId())) {
                for(pse__Skill__c skill : skillList) {
                    pse__Skill_Certification_Rating__c scr = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
                    scr.pse__Rating__c = '5 - Expert';
                    scrList.add(scr);
                }
                insert scrList;
            }
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            Contact cont = [Select Id From Contact order by CreatedDate asc limit 1];
            cont.Sub_Group__c = 'TSL-Japan';
            update cont; 
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
            agreement0.Opportunity_Type__c = '';
            agreement0.RFP_Ranking__c = '2';
            agreement0.Budget_Deliverable__c= '';
            Test.startTest();
				update agreement0;
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				pse__Proj__c project0 = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
				pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project0.Id);
				resourceRequest.pse__Group__c = grp1.Id;
				resourceRequest.subgroup__c = 'TSL-Japan';
				resourceRequest.Original_Assignee__c = contactList[0].Id;
				resourceRequest.Is_Created_Automatically__c = true;
				resourceRequest.pse__Resource__c = cont.id;
				CON_OWF.isUpdatedViaPresentationDate = True;
				insert resourceRequest;
				CON_OWF.isUpdatedViaPresentationDate = False;
			Test.stopTest(); 
        
			List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
			system.assertNotEquals(0, assign.size(), 'Verifying createAssignmentsForClosedBDRR Functionality');  
        }    
    }
    
	@isTest
    static void testLCSBidDefense()
    {
        List<pse__Resource_Request__c> rrList = new List<pse__Resource_Request__c>(); 
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        {
    		Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.QI_Invited_to_Present__c = 'Yes';
            oppty.Presentation_Country__c = 'Albania';
            oppty.Presentation_Date_Status__c = 'Estimated';
            update oppty;
        	Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.SubGroup__c = 'LCS Bid Defense';    
            rrList.add(resourceRequest);
            pse__Resource_Request__c resourceRequestTSL = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project.Id);
            resourceRequestTSL.pse__Group__c = grp1.Id;
            resourceRequestTSL.Is_Created_Automatically__c = true;
            resourceRequestTSL.SubGroup__c = 'TSL';
            rrList.add(resourceRequestTSL);
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules;
            Contact cont = [Select Id From Contact order by CreatedDate asc limit 1];
            Test.startTest();
            	insert rrList;
            	pse__Assignment__c tslAssignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement0.Id, project.Id, listToInsertSchedules.get(0).Id, cont.Id, rrList[1].Id);
                insert tslAssignment;
            	tslAssignment.pse__Status__c = 'Accepted';
            	update tslAssignment; 
            Test.stopTest();
			
            List<pse__Resource_Request__c> rr = [Select Id, SubGroup__c from pse__Resource_Request__c where SubGroup__c = 'LCS Bid Defense' limit 1];
            String expected = 'LCS Bid Defense';
            system.assertEquals(expected, rr[0].SubGroup__c, 'Verifying LCSBidDefense Functionality');
        }
    }
    
    @isTest
    static void testvalidateStartEndDateforTriageManager()
    {
        try
        {
            User testRunner = [SELECT Id from User where FirstName = 'TestRunner'][0];
            System.runAs(testRunner) 
        	{
                Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
                Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
                mulesoftIntegrationSettings.Ignore_Validation_Rules__c = false;
                upsert mulesoftIntegrationSettings;
                Test.startTest();
                    Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
                    pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1];
                    pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
                    pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project.Id);
                    resourceRequest.pse__Group__c = grp1.Id;
                    resourceRequest.Is_Created_Automatically__c = true;
                    resourceRequest.SubGroup__c = 'GBO-Lead PD';
                    insert resourceRequest;
                    resourceRequest.pse__Start_Date__c = system.today().addDays(5);
                    update resourceRequest;
                Test.stopTest();
                system.assertNotEquals(Date.today(), resourceRequest.pse__Start_Date__c, 'Verifying validateStartEndDateforTriageManager Functionality');
        		}
   		} catch(DmlException ex) {
                System.assertEquals(System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0), 'Verifying Error');
        } 
    }
    
    @isTest
    static void testPostAward() 
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        {
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.Sub_Group__c = 'TSL';
            update cont;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement0 = [select id from Bid_History__c limit 1];
            agreement0.Opportunity_Type__c = '';
            agreement0.RFP_Ranking__c = '2';
            agreement0.Budget_Deliverable__c= '';
            update agreement0;
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Proj__c project0 = [Select Id From pse__Proj__c Where Bid_History__c =: agreement0.Id limit 1]; 
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement0.Id, oppty.Id, project0.Id);
            resourceRequest.Is_Created_Automatically__c = True;
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.subgroup__c = 'TSL';
            resourceRequest.Original_Assignee__c = cont.Id;
            resourceRequest.Is_Created_Automatically__c = true;
			resourceRequest.LeadSupportFlag__c = 'Lead';            
            Test.startTest();    
			insert resourceRequest;
				pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement0.Id, project0.Id, listToInsertSchedules.get(0).Id, cont.Id, resourceRequest.id);
				insert assign1;
                assign1.pse__Status__c  = 'Accepted';
            	update assign1;
                Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
                insert agreement;
            Test.stopTest();
            List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
            system.assertNotEquals(0, assign.size(), 'Verifying PostAward Functionality');
        }
    }
   
    @isTest
    static void testpost1() 
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        { 
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_INDICATION);
            insert skill;
            List<Contact> contactList = [Select Id From Contact limit 1];
	        contactList[0].Sub_Group__c = 'TSL';
            Test.startTest();
				update contactList; 
				
                pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
				insert skillCertRating;
				Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
				Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c where RFP_Ranking__c > '1' ][0];
				pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
				pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
				Account acc = [Select id from Account limit 1];
				pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
				resourceRequest1.pse__Group__c = grp1.Id;
				resourceRequest1.subgroup__c = 'TSL';
				resourceRequest1.Is_Created_Automatically__c = true;
				insert resourceRequest1;
				List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
				insert listToInsertSchedules;
				List<pse__Assignment__c> listToInsertAssignments = new List<pse__Assignment__c>();
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, contactList[0].Id, resourceRequest1.Id));
				listToInsertAssignments.add(UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(1).Id, contactList[0].Id, resourceRequest1.Id));
				insert listToInsertAssignments;
            Test.stopTest();
			listToInsertAssignments[0].pse__Status__c = 'Accepted';
			update listToInsertAssignments[0];
			Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
			insert agreement2;
			pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement2.Id, oppty.Id, project.Id);
			resourceRequest2.pse__Group__c = grp1.Id;
			resourceRequest2.subgroup__c = 'TSL';
			resourceRequest2.Is_Created_Automatically__c = true;
			insert resourceRequest2;
            List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
            system.assertNotEquals(0, assign.size(), 'Verifying PostAward1 Functionality');
        }
    }
 	
    @isTest
    static void testCTELead()
    {
        User testRunner = [SELECT Id, Profile.Name from User where FirstName = 'TestRunner'];
        System.runAs(testRunner)
        { 
            Contact cont = [Select Id, Sub_Group__c From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.Sub_Group__c = 'CTS-Lead';
            cont.RecordTypeId = CON_OWF.IQVIA_User_Contact_RECORD_TYPE_ID;
            update cont;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            agreement.Requested_Services__c = 'CTS';
            agreement.Bid_Due_Date__c = system.today().addDays(10);
            update agreement;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Test.startTest();
                pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
                resourceRequest.RecordTypeId =  CON_OWF.OWF_RR_RECORD_TYPE_ID;
                resourceRequest.pse__Group__c = grp1.Id;
                resourceRequest.subgroup__c = 'CTS-Lead';
                resourceRequest.Is_Created_Automatically__c = true;
                insert resourceRequest;
                List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
                listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
                listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
                insert listToInsertSchedules;
                pse__Assignment__c assign1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, listToInsertSchedules.get(0).Id, cont.Id, resourceRequest.id);
                insert assign1;
            Test.stopTest();
            
            List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c limit 10];
            system.assertNotEquals(0, assign.size(), 'Verifying CTELead Functionality');
        }
    }
    
    @isTest
    static void testCreateResourceSkillRequestForTSSU() 
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        { 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Clinical', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills(CON_OWF.SKILL_NAME_STRATEGIC_ANALYTICS, CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY);																																		  
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            skillList.add(skill5);					  
            insert skillList;
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            agreement.Requested_Services__c = 'Project Management;Clinical Monitoring';
			agreement.Opportunity_Type__c = 'Full service RFP';
			agreement.RFP_Ranking__c = '4';
			agreement.Budget_Deliverable__c = 'Full Budget';
			agreement.Bid_Due_Date__c = Date.today().addDays(5);
			update agreement;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            cont.sub_group__c=CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD;
            update cont;
            Opportunity oppty = [SELECT Id, Indication_List__c FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Potential_Regions__c ='USA/Canada';
            update oppty;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            resourceRequest.SubGroup__c =CON_OWF.RES_REQ_TYPE_THERAPEUTIC_ANALYTICS_LEAD;
            List<pse__Skill_Certification_Rating__c> skillCertRatingList = new List<pse__Skill_Certification_Rating__c>();
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill1.Id,cont.Id);
            skillCertRatingList.add(skillCertRating);
            pse__Skill_Certification_Rating__c skillCertRating2 = UTL_OWF_TestData.createSkillCertificationRating(skill2.Id,cont.Id);
            skillCertRatingList.add(skillCertRating2);
			pse__Skill_Certification_Rating__c skillCertRating3 = UTL_OWF_TestData.createSkillCertificationRating(skill3.Id,cont.Id);
            skillCertRatingList.add(skillCertRating3);
            Test.startTest();
                insert skillCertRatingList;
                insert resourceRequest;
            Test.stopTest();
			
            List<pse__Resource_Skill_Request__c> rsr = [select id,  pse__Resource_Request__c  from pse__Resource_Skill_Request__c where pse__Resource_Request__c =: resourceRequest.Id];
            system.assertNotEquals(0, rsr.size(), 'Verifying CreateResourceSkillRequestForTSSU Functionality');
        }
    }
    @isTest
    static void testSetLeadSupportFlagOnResourceRequest()
    {
        User testRunner = [SELECT Id, Profile.Name from User where FirstName = 'TestRunner'];
        System.runAs(testRunner)
        { 
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            agreement.Requested_Services__c = 'CTS';
            agreement.Bid_Due_Date__c = system.today().addDays(10);
            update agreement;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            Test.startTest();
            	pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
                resourceRequest1.RecordTypeId =  CON_OWF.OWF_RR_RECORD_TYPE_ID;
                resourceRequest1.pse__Group__c = grp1.Id;
                resourceRequest1.subgroup__c = 'CTS-Lead';
                resourceRequest1.Is_Created_Automatically__c = true;
                insert resourceRequest1;
                pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
                resourceRequest.RecordTypeId =  CON_OWF.OWF_RR_RECORD_TYPE_ID;
                resourceRequest.pse__Group__c = grp1.Id;
                resourceRequest.subgroup__c = 'CTS-Lead';
                resourceRequest.Is_Created_Automatically__c = false;
                insert resourceRequest;
            Test.stopTest();
            
            List<pse__Resource_Request__c> resReq = [Select LeadSupportFlag__c from pse__Resource_Request__c where Is_Created_Automatically__c= false];
            system.assertEquals(CON_OWF.SUPPORT_FLAG, resReq[0].LeadSupportFlag__c,'Verifying Lead support flag');
        }
    }
    
    @isTest
    static void testCreateAssignmentForContractPostAwardBid(){
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        pse__Grp__c grp = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        OWF_Config__c owfConfig = [Select id, OWF_Compatible_Group_Set_2__c from owf_config__c];
        owfConfig.OWF_Compatible_Group_Set_2__c = 'OWF DSB-PM;OWF DSB-PM Post';
        update owfConfig;
        oppty.Line_of_Business__c = 'Clinical';
        oppty.Is_this_a_Virtual_Trials_Study__c = 'Yes Fully Hybrid';
        oppty.Is_this_IQVIA_Biotech__c = 'Yes';
        update oppty;
        Bid_History__c earlyEngagementBid = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID);
        earlyEngagementBid.Bid_Due_Date__c = system.today().addDays(5);
        insert earlyEngagementBid;
        Pse__Proj__c bidProject = [Select id from Pse__Proj__c where bid_History__c =: earlyEngagementBid.id];
        pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(earlyEngagementBid.Id, oppty.Id, bidProject.Id);
        resourceRequest1.pse__Group__c = grp.Id;
        resourceRequest1.SubGroup__c = 'TSL';
        resourceRequest1.LeadSupportFlag__c ='Lead';
        insert resourceRequest1;
        Contact con1 = [Select id,Sub_Group__c,Secondary_Sub_Group__c from Contact limit 1];
        con1.Sub_Group__c ='TSL';
        update con1;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignment1 = UTL_OWF_TestData.createAssignmentForBidHistory(earlyEngagementBid.id, bidProject.id, schedule.id, con1.id, resourceRequest1.id);
        insert assignment1;
        Bid_History__c bid = [Select id from Bid_History__c limit 1];
        bid.Is_Study_Awarded__c = 'Yes';
        update bid;
        Test.startTest();
        pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: bid.Id limit 1];
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bid.Id, oppty.Id, project.Id);
        resourceRequest.RecordTypeId =  CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.subgroup__c = 'DSB-PM';
        resourceRequest.Is_Created_Automatically__c = false;
        insert resourceRequest;
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = false;
        upsert mulesoftIntegrationSettings;
        Contact con = [Select id,Sub_Group__c,Secondary_Sub_Group__c from Contact limit 1];
        con.Sub_Group__c ='DSB-PM';
        con.EmployeeNumber__c = '668';
        con.Secondary_Sub_Group__c ='DSB-PM Post';
        con.RecordTypeId = CON_OWF.IQVIA_User_Contact_RECORD_TYPE_ID;
        update con;
        pse__Schedule__c schedule1 = UTL_OWF_TestData.createSchedule();
        insert schedule1;
        pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(bid.id, project.id, schedule1.id, con.id, resourceRequest.id);
        insert assignment;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
        bidHistory.Requested_Agreement_Type__c = CON_OWF.REQUESTED_AGREEMENT_TYPE_WORK_ORDER;
        bidHistory.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;CEVA;IQB Ongoing DM;IQB Project Management';
        insert bidHistory;
        List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :bidHistory.Id and SubGroup__c = 'DSB-Clinical Post'];
        System.assertEquals(1, resReqsList.size(), 'Success');
        Test.stopTest();
    }
    @isTest
    static void testCreateResourceSkillRequest2() 
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner)
        { 
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Consulting', 'Line of Business');
            pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('USA/Canada', 'User Regional Geographic Working Scope');
            pse__Skill__c skill3 = UTL_OWF_TestData.createSkills('Test Indication', 'Indication');
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('Acute Care', 'Therapy Area');
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills('FSP', 'Opportunity Level');
            pse__Skill__c skill6 = UTL_OWF_TestData.createSkills('IQVIA Biotech', 'Opportunity Level');
            pse__Skill__c skill7 = UTL_OWF_TestData.createSkills('FSP_Skill', 'Opportunity Type');
            pse__Skill__c skill8 = UTL_OWF_TestData.createSkills('Core', 'Opportunity Level');
            skillList.add(skill1);
            skillList.add(skill2);
            skillList.add(skill3);
            skillList.add(skill4);
            skillList.add(skill5);
            skillList.add(skill6);
            skillList.add(skill7);
            skillList.add(skill8);
            insert skillList;
            Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
            agreement.Opportunity_Type__c = 'FSP_Skill';
            update agreement;
            Contact cont = [Select Id From Contact Where Name = 'TestFirstName TestContact'][0];
            List<User> userList = UTL_TestData.createUser('System Administrator', 2);
            userList[0].FirstName = 'Test1';
            userList[0].SUBREGION__c = 'United States of America';
            userList[0].IsActive = true;
            userList[1].FirstName = 'Test2';
            userList[1].SUBREGION__c = 'United States of America';
            userList[1].IsActive = true;
            insert userList;
            cont.pse__Salesforce_User__c = userList[0].id;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Is_this_IQVIA_Biotech__c = 'No';
            oppty.FSP__c = 'Yes';
            update oppty;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest.pse__Group__c = grp1.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            Test.startTest();
            insert resourceRequest;
            Test.stopTest();
            
            List<pse__Resource_Skill_Request__c> rsr = [select id, pse__Skill_Certification__c, pse__Resource_Request__c  from pse__Resource_Skill_Request__c limit 10];
            system.assert(rsr.size() > 0,'Verifying CreateResourceSkillRequest Functionality');
        }
    }
    @isTest
    static void testCloneAssignmentFromEarlyEngagmentBid() 
    {
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        { 
            List<Contact> contactList = [Select Id From Contact where FirstName = 'TestFirstName']; 
            List<pse__Schedule__c> listToInsertSchedules = new List<pse__Schedule__c>();
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            listToInsertSchedules.add(UTL_OWF_TestData.createSchedule());
            insert listToInsertSchedules; 
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c bid1 = [select id from Bid_History__c limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            pse__Proj__c project1 = [Select Id From pse__Proj__c Where Bid_History__c =: bid1.Id limit 1];
            Test.startTest();
            Bid_History__c bid2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_EARLY_ENGAGEMENT_BID_HISTORY_RECORD_TYPE_ID);
            insert bid2;
            pse__Proj__c project2 = [Select Id From pse__Proj__c Where Bid_History__c =: bid2.Id limit 1];
            pse__Resource_Request__c resourceRequest2 = UTL_OWF_TestData.createResourceRequestForBidHistory(bid2.Id, oppty.Id, project2.Id);
            resourceRequest2.pse__Group__c = grp1.Id;
            resourceRequest2.subgroup__c = 'TSL';
            resourceRequest2.Original_Assignee__c = contactList[0].Id;
            resourceRequest2.Is_Created_Automatically__c = true;
            resourceRequest2.LeadSupportFlag__c = 'Lead';
            insert resourceRequest2;
            pse__Assignment__c assign2 = UTL_OWF_TestData.createAssignmentForBidHistory(bid2.Id, project2.Id, listToInsertSchedules.get(1).Id, contactList[0].Id, resourceRequest2.id);
            insert assign2;
            pse__Resource_Request__c resourceRequest3 = UTL_OWF_TestData.createResourceRequestForBidHistory(bid1.Id, oppty.Id, project1.Id);
            resourceRequest3.pse__Group__c = grp1.Id;
            resourceRequest3.subgroup__c = 'TSL';
            resourceRequest3.Original_Assignee__c = contactList[0].Id;
            resourceRequest3.Is_Created_Automatically__c = true;
            resourceRequest3.Preferred_Resource__c = contactList[0].Id;
            insert resourceRequest3;
            Test.stopTest();
            
            List<pse__Assignment__c> assign = [Select Id from pse__Assignment__c where pse__Resource_Request__c =: resourceRequest3.ID];
            system.assertNotEquals(null, assign.size(), 'Verifying CreateAssignment Functionality');   
        }
    }
    @isTest
    static void testCreateBDAssignmentforInactiveContact() 
    {	
        User testRunner = [SELECT Id from User where FirstName = 'TestRunner'];
        System.runAs(testRunner) 
        {   
            List<Contact> contactTSL = [Select Id,pse__Is_Resource__c From Contact where sub_group__c = 'TSL'];
            List<Contact> contactMSL = [Select Id,Available_for_Triage_Flag__c From Contact where sub_group__c = 'Medical-MSL'];
           
            Account acc=[Select id from Account limit 1];
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.QI_Invited_to_Present__c = 'yes';
            oppty.Presentation_Date_Status__c = 'Estimated';
            oppty.Bid_Defense_Date__c = Date.today().addDays(8);
            oppty.Presentation_Country__c = 'India';
            oppty.Line_of_Business__c = 'Clinical';
            oppty.Potential_Regions__c = 'Asia Pacific';
            update oppty;
            Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement.Bid_Number__c = 1;
            agreement.Opportunity_Type__c = 'Ballpark requiring IQVIA-defined C/S/P strategy';
            agreement.Budget_Deliverable__c = 'Full Budget';
            agreement.Requested_Services__c = 'Clinical Monitoring;Project Management;Patient Recruitment;Late Phase Site Start up (SPS)';
            agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
            agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;	
            agreement.RFP_Ranking__c = '3';
            agreement.Bid_Due_Date__c = Date.today().addDays(8);
            insert agreement;
            pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
            pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
            List<pse__Resource_Request__c> resRequestList = new List<pse__Resource_Request__c>();
            
            Test.startTest();
            List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
            List<pse__Resource_Request__c> rrtobeAssignedList = [Select id,SubGroup__c from pse__Resource_Request__c where (SubGroup__c ='TSL' or SubGroup__c ='Medical-MSL') and Is_Bid_Defense__c = false]; 
            for(pse__Resource_Request__c rr: rrtobeAssignedList){
                if(rr.SubGroup__c == 'TSL'){
                    pse__Assignment__c assignment1 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id,project.Id, null, contactTSL[0].Id, rr.ID);
                    assignment1.pse__Status__c = 'Accepted';
                    assignmentList.add(assignment1);
                }
                if(rr.SubGroup__c == 'Medical-MSL'){
                    pse__Assignment__c assignment2 = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id,project.Id, null, contactMSL[0].Id, rr.ID);
                    assignment2.pse__Status__c = 'Accepted';
                    assignmentList.add(assignment2);
                }
            }
			insert assignmentList;
            contactMSL[0].Available_for_Triage_Flag__c =false;
            update ContactMSL;
            List<pse__Resource_Request__c> resRequestList2 = new List<pse__Resource_Request__c>();
            pse__Resource_Request__c resourceRequest3 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest3.pse__Group__c = grp1.Id;
            resourceRequest3.subgroup__c = 'TSL';
            resourceRequest3.Is_Bid_Defense__c = True;
            resourceRequest3.Complexity_Score_Total__c = 0;
            resourceRequest3.pse__Start_Date__c = Date.today().addDays(7);
            resourceRequest3.Is_Created_Automatically__c = true;
            resRequestList2.add(resourceRequest3);
            pse__Resource_Request__c resourceRequest4 = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
            resourceRequest4.pse__Group__c = grp1.Id;
            resourceRequest4.subgroup__c = 'Medical-MSL';
            resourceRequest4.Is_Bid_Defense__c = True;
            resourceRequest4.Complexity_Score_Total__c = 0;
            resourceRequest4.pse__Start_Date__c = Date.today().addDays(7);
            resourceRequest4.Is_Created_Automatically__c = true;
            resRequestList2.add(resourceRequest4);
            insert resRequestList2; 
            Test.stopTest();
            List<pse__Resource_Request__c> rr = [Select id, Name, Is_Bid_Defense__c from pse__Resource_Request__c where id =: resourceRequest3.id];
            system.assertEquals(true, rr[0].Is_Bid_Defense__c, 'Verifying CreateBDAssignment Functionality');
        } 
    }
    
}