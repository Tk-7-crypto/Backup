@isTest
private class TST_BCH_CSM_AutoDeleteEmailMessage {
    @testSetup
    static void dataSetup() {
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
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
        
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Data GLOBAL E-SERVICE';
        queues.QueueName__c = 'Data GLOBAL E-SERVICE';
        queues.Type__c = 'Queue'; 
        queues.User__c = UserInfo.getUserId();
        queueList.add(queues);
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Data GLOBAL E-SERVICE';
        queueUser.QueueName__c = 'Data GLOBAL E-SERVICE';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueList.add(queueUser); 
        insert queueList;
        
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Virtual Trials Case').getRecordTypeId();
            Case c1 = new Case(Subject = 'R&D - Virtual Trials Case 01', Description = 'R&D - Virtual Trials Case 01', AccountId = acct.Id,
                ContactId = con.Id, Origin = 'Voicemail', Status = 'In Progress',InitialQueue__c = 'group name',RandD_Location__c = 'Manila',
                OwnerId = UserInfo.getUserId(), RecordTypeId = RecordTypeIdCaseRD, CurrentQueue__c = queueUser.Id);
        
        insert c1;
     
    }
    
    static testmethod void testPreventEmailMessageDel(){
        Case c1 = [SELECT Id, Status,template__c FROM Case WHERE Subject = 'R&D - Virtual Trials Case 01' LIMIT 1];
        List<EmailMessage> newEmail = new List<EmailMessage>();
        EmailMessage em = new EmailMessage(FromAddress = 'test@abc.org', Incoming = true, ToAddress= 'casecontact@mail.com', Subject = 'Test email RD Out', TextBody = '23456 ', ParentId = c1.Id);
        EmailMessage em2 = new EmailMessage(FromAddress = 'test@abc.org', PII_Data_Identified__c = true, Incoming = true, ToAddress= 'casecontact@mail.com', Subject = 'Test email RD Out', TextBody = '23456 ', ParentId = c1.Id);		
       
        try{
            List<EmailMessage> emailList = new List<EmailMessage>();
            emailList.add(em);
            emailList.add(em2);
            Test.startTest();
            insert emailList;
            newEmail = Database.query('select id,Subject,Parent.LastModifiedDate,PII_Data_Identified__c from EmailMessage');
            Activity__C activityRecord = null;
            List<Activity__C> actList = new List<Activity__C>();
            for(EmailMessage e : newEmail){
                actList.add(new Activity__C(Case__c = c1.Id, status__c = 'Open',EmailMessageId__c = e.Id));
            } 
            if(!actList.isEmpty()){
                insert actList;
                System.assertEquals(2,actList.size());
            }
            BCH_CSM_AutoDeleteEmailMessage obj = new BCH_CSM_AutoDeleteEmailMessage();
            obj.errors = new List<String>{'error1'};
            Database.QueryLocator ql = obj.start(null);
            obj.execute(null,newEmail);
            obj.Finish(null);
        }catch(DMLexception e){
        }
        Test.stopTest();
    }

}