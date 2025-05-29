@isTest
public class TST_CNT_CSM_Timer {
    
    static testmethod void testupdateStatusforLogAWorkNoteonCase(){
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(TECH_QueueUser__c = qur.Id,
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case cs2 = new Case();
            cs2.ContactId = con.Id;
            cs2.AccountId = acct.Id;
            cs2.AssignCaseToCurrentUser__c = false;
            cs2.OwnerId = UserInfo.getUserId();
            cs2.CurrentQueue__c = qur.Id;
            cs2.RecordTypeId = RecordTypeIdCase;
            cs2.Origin = 'Chat';
            cs2.Mail_CC_List__c = 'nodata@info.com';
            cs2.Subject = 'Techno case';
            cs2.Description = 'Test class to check case creation';
            cs2.Status = 'New';
            insert cs2;
            CNT_CSM_Timer.insertorUpdateTime(cs2.Id,'Estimated effort','TechnologyCase');
            CNT_CSM_Timer.getManaulTimeSheet(cs2.Id,null);
            TimeSheet__c s1 = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = cs2.Id, Status__c = 'start',Time_Type__c = 'Estimated effort');
            insert s1;
            CNT_CSM_Timer.insertTime(cs2.Id,'Estimated effort');
            TimeSheet__c sheet = [Select Id From TimeSheet__c LIMIT 1];
            CNT_CSM_Timer.getTimeTypeList(cs2.Id);
            CNT_CSM_Timer.getTimeSheet(cs2.Id,null);
            CNT_CSM_Timer.getManaulTimeSheet(cs2.Id,null);
            CNT_CSM_Timer.insertTime(cs2.Id,'Estimated effort');
            CNT_CSM_Timer.insertorUpdateTime(cs2.Id,'Estimated effort','TechnologyCase');
            CNT_CSM_Timer.saveTimeSheet(cs2.Id ,2, 'Test Case','Estimated effort','','','',1);
            CNT_CSM_Timer.updateAutoStopTime(cs2.Id, s1.Id,'Estimated effort','','','');
            CNT_CSM_Timer.updateStopTime(cs2.Id,sheet.Id,'Estimated effort');
            
           
            
            TimeSheet__c s = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = cs2.Id, Status__c = 'start',Time_Type__c = 'Estimated effort');
            insert s;
            CNT_CSM_Timer.updateStopTimefromCase(new Set<Id>{cs2.Id},'Case Updated');
            TimeSheet__c s2 = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = cs2.Id, Status__c = 'autostop',Time_Type__c = 'Estimated effort');
            insert s2;
            CNT_CSM_Timer.insertorUpdateTime(cs2.Id,'Estimated effort','TechnologyCase');
            
            /*LIAssignment__x assignment = new LIAssignment__x();
            //assignment.Name__c ='Test assignement';
            DateTime dT = System.now();
            Date today = date.newinstance(dT.year(), dT.month(), dT.day());
            //assignment.pse_Start_Date_c__c = System.now();
            //assignment.pse_End_Date_c__c = System.now().addDays(5);
            //assignment.pse_Project_c__c='project1';
            assignment.pse_Status_c__c = 'Scheduled';
            assignment.pse_Closed_for_Time_Entry_c__c =false;
            assignment.pse_Project_c__r.pse_Start_Date_c__c=today;
            assignment.pse_Project_c__r.pse_End_Date_c__c=today.addDays(5);
            assignment.pse_Project_c__r.pse_Closed_for_Time_Entry_c__c = false;
            assignment.pse_Project_c__r.pse_Stage_c__c ='In Progress (At Risk)';
            //insert assignment;
            
            
            LIMilestone__x milestone = new LIMilestone__x(pse_Project_c__c='project1',Name__C='test milestone',pse_Status_c__c='Open',Start_Date_c__c=today
                                                          ,End_Date_c__c=today.addDays(5));
            
            //insert milestone;*/
            CNT_CSM_Timer.RecordCreatedThisWeek_Count();
            boolean result = CNT_CSM_Timer.CheckForValidation('','','');
            result = CNT_CSM_Timer.CheckForValidation('','','','');
            CNT_CSM_Timer.getMilestones('');
            CNT_CSM_Timer.getTimesheetRecordById(sheet.Id);
            CNT_CSM_Timer.checkEligibilityForExplictUpdate(u.Id);
            CNT_CSM_Timer.checkIfEligibleToUpdatePSADetails(sheet.Id);
            CNT_CSM_Timer.SendDataFromUser();
            CNT_CSM_Timer.updateDataPSA(sheet.Id,'','','');
            CNT_CSM_Timer.getAssignmentsAndProjects();
        }
    }

}