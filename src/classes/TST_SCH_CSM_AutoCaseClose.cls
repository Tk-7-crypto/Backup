@isTest
private class TST_SCH_CSM_AutoCaseClose {
    static testMethod void testAutoCaseClose() 
    {
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Account acct1 = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct1;
        /* Added Start */
        Account acct2 = new Account(
            Name = 'TestAcc2',
            RDCategorization__c = 'Sponsor',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com');
        insert Con;
        
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct2.Id,Type = 'R_D',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        Case c = new Case(
            AccountId = acct2.Id,
            ContactId = con.Id,
            Study__c =study.Id,
            Sponsor__c = acct2.Id,   
            Origin = 'Chat',
            Status = 'Resolved',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            //EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        try{
            insert c;  
        }catch (DmlException e) {
            System.debug('Failed to Insert :'+e);
        }
        
        Test.startTest();
        SCH_CSM_AutoCaseClose sch = new SCH_CSM_AutoCaseClose();
        SchedulableContext sc = null;
        sch.execute(sc);
        BCH_CSM_AutoCaseClose obj = new BCH_CSM_AutoCaseClose();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}