@isTest
private class TST_SRV_CSM_EntitlementMilestoneCalc {
    static testMethod void testMilestoneTimeCalculator() {        
        // Select an existing milestone type to test with
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType where Name = 'Resolution Time' LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        // Create case data.
        // Typically, the milestone type is related to the case, 
        // but for simplicity, the case is created separately for this test.
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',
            AccountId = acct.Id,PreferredLanguage__c = 'en_US');
        insert Con;
        List<SlaProcess> slaList = Database.query('select Id, Name, NameNorm, Description, IsActive, VersionNumber, IsVersionDefault, VersionNotes, VersionMaster, StartDateField, SobjectType, BusinessHoursId, LastViewedDate from SlaProcess where IsActive=true and Name =\'CSM TECHNO Entitlement Process Translation Team\' LIMIT 1');
        
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        if(slaList != null && !slaList.isEmpty()){
            ent.SlaProcessId = slaList[0].Id;
        }
        insert ent;
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        SRV_CSM_EntitlementMilestoneCalc calculator = new SRV_CSM_EntitlementMilestoneCalc();
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue', DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Tier__c ='Tier 1', Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId,Business_Hours__c = bhId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Tier__c ='Tier 1', Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Urgency__c = 'High';
            cs.Priority = 'Priority 4';
            cs.Origin = 'Email';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            Date dt = System.today();
            dt = dt.addDays(5);
            cs.ETA_Date__c = dt;
            Test.startTest();
            insert cs;
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            cs.Urgency__c = 'Low';
            update cs;
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            Test.stopTest();
        }
        
    }
}