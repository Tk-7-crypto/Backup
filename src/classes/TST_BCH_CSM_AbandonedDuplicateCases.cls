@isTest
private class TST_BCH_CSM_AbandonedDuplicateCases {

   @testSetup
    static void dataSetup() {
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestActBatch', phone='1001231234', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(myAcc);
        Account busAcc = new Account(Name = 'TestForMSBatch', phone='4567890999', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(busAcc);
        insert acts;
        
        Account acct2 = new Account(Name = 'TestAcc2Batch',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudyBatch', Sponsor__c = acct2.Id);
        insert study;
        
        Contact cont = new Contact(FirstName = 'TestBatch', LastName = 'LastName', phone='4567890999',
                                   accountid = busAcc.id,PreferredLanguage__c = 'en_US');
        insert(cont);
        Id contactId = cont.Id;
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cont.Id,Site_Name__c = acts[1].Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        Entitlement entl = new Entitlement(Name='TestEntitlementBatch', AccountId=busAcc.Id, BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id);
        insert entl;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='RnD Queue Batch', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            Queue_User_Relationship__c qu = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'Queue', Tier__c ='Tier 1',
                Group_Id__c = grpUser.groupId);
            
            insert qu;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,TECH_QueueUser__c = qu.Id,
                Type__c = 'User', Tier__c ='Tier 1',
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
            String entlId;
            if (entl != null)
                entlId = entl.Id;
            List<Case> cases = new List<Case>{};
                if (entlId != null){
                    Case c = new Case(Subject = 'Test Case with EntitlementBatch',Study__c=study.Id,Sponsor__c = acct2.Id, Site_Related_to_the_Study__c = siteConR.Id,
                                      Origin = 'Email',Status = 'New',InitialQueue__c = 'Q1',AssignCaseToCurrentUser__c = false,RandD_Location__c = 'Dalian',
                                      EntitlementId = entlId, ContactId = contactId, SuppliedEmail = 'mallikarjuna.reddyb@iqvia.com', RecordTypeId = RecordTypeIdCase);
                    cases.add(c);
                    Case c2 = new Case(Subject = 'Test Case with EntitlementBatch',Study__c=study.Id,Sponsor__c = acct2.Id,
                                       Site_Related_to_the_Study__c = siteConR.Id, Origin = 'Email', Status = 'New',
                                       InitialQueue__c = 'Q1', AssignCaseToCurrentUser__c = false,RandD_Location__c = 'Dalian',
                                       EntitlementId = entlId, ContactId = contactId,SuppliedEmail = 'mallikarjuna.reddyb@iqvia.com', RecordTypeId = RecordTypeIdCase);
                    cases.add(c2);
                }
            insert cases;
        }

    }
    
     @isTest
    static void testCaseAbandonBatch() {
        Test.startTest();
        BCH_CSM_AbandonedDuplicateCases batch = new BCH_CSM_AbandonedDuplicateCases();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
    }
}