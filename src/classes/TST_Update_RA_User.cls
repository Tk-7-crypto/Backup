@isTest
private class TST_Update_RA_User {
     @testsetup
    static void datasetup() {
        Account NewAccount = new Account(Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert NewAccount;
        User testUser = [Select id, name from User where isActive = true AND id =: UserInfo.getUserId() Limit 1];
        Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        insert ratest;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity NewOpportunity = new Opportunity(Name='Test Opp');
        NewOpportunity.AccountId = NewAccount.Id;
        NewOpportunity.StageName = '7a. Closed Won';
        NewOpportunity.CloseDate = System.today();
        NewOpportunity.Contract_Term__c='Single-Period';
        NewOpportunity.Contract_End_Date__c = system.today();
        NewOpportunity.Contract_Start_Date__c = system.today();
        NewOpportunity.CurrencyIsoCode = 'USD';
        NewOpportunity.Potential_Competitor_1__c = comp.Id;		   
        insert NewOpportunity;
        Address__c TestAddress = New Address__c(Name='Test Address',Account__c = NewAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
        SAP_Reference__c = '495001');
        TestAddress.MDM_Validation_Status__c = 'Validated';
        TestAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert TestAddress;
        
        BNF2__c TestBnf = new BNF2__c(Opportunity__c = NewOpportunity.Id);
        TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
        TestBnf.Sales_Org_Code__c = 'ES51';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain [ES51]';
        TestBnf.Ship_To__c = TestAddress.Id;
        TestBnf.Bill_To__c = TestAddress.Id;
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Revenue_Analyst__c = ratest.Id;
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        insert TestBnf;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestBnf.Id);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
      @istest
    static void testChangeRABNF() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        List<User> userlist= new List<User>();
        for (Integer k=0;k<10;k++) { 
            userlist.add(new User(Alias = 'standt', Email='standarduser@metacube.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3144'+k+'@metacube.com' , isactive = true, Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808'+k));
        }
        insert userlist;
        
       /*	Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
        insert q1;
        List<GroupMember> gpList = new List<GroupMember>();
        
        for (Integer k=0;k<10;k++) { 
            gpList.add( new GroupMember(UserorGroupId=userlist.get(k).Id,GroupId=g1.Id));
        }
        insert gpList; */
        Test.startTest();
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',
            User__c = userlist[0].id /*,
            User_2__c = userlist[1].id,
            User_3__c = userlist[2].id,
            User_4__c = userlist[3].id,
            User_5__c = userlist[4].id,
            User_6__c = userlist[5].id,  
            User_7__c = userlist[6].id,
            User_8__c = userlist[7].id,
            User_9__c = userlist[8].id,
            User_10__c = userlist[9].id*/);                                                                 
        insert TestLocalRA;
       
        BNF2__c TestBNF  = [Select id, Revenue_Analyst__c from BNF2__c Limit 1];
        TestBNF.Revenue_Analyst__c = TestLocalRA.id;
        upsert testBNF;
        Test.stopTest();
       }
    
    @istest
    static void testChangeRABNFInactive() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        List<User> userlist= new List<User>();
        for (Integer k=0;k<10;k++) { 
            userlist.add(new User(Alias = 'standt', Email='standarduser@metacube.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3144'+k+'@metacube.com', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808'+k));
        }
        userlist[0].isactive = false;
        userlist[1].isactive = false;
        userlist[2].isactive = false;
        userlist[3].isactive = false;
        userlist[4].isactive = false;
        userlist[5].isactive = false;
        userlist[6].isactive = false;
        userlist[7].isactive = false;
        userlist[8].isactive = false;
        insert userlist;
        Group g1;
        system.runAs(userlist[9]){
	        g1 = new Group(Name='group name', type='Queue');
	        insert g1;
	        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
	        insert q1;
	        List<GroupMember> gpList = new List<GroupMember>();
	        
	        for (Integer k=0;k<10;k++) { 
	            gpList.add( new GroupMember(UserorGroupId=userlist.get(k).Id,GroupId=g1.Id));
	        }
	        insert gpList;
        }
        
        //Group g2 = [select id from ]
        
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA', ownerid = g1.id, Revenue_Analyst_Email__c='a@gmail.com',
            User__c = userlist[9].id,
            User_2__c = userlist[1].id,
            User_3__c = userlist[2].id,
            User_4__c = userlist[3].id,
            User_5__c = userlist[4].id,
            User_6__c = userlist[5].id,  
            User_7__c = userlist[6].id,
            User_8__c = userlist[7].id,
            User_9__c = userlist[8].id,
            User_10__c = userlist[0].id); 
        
        insert TestLocalRA;
        Test.startTest();
        BNF2__c TestBNF  = [Select id, Revenue_Analyst__c from BNF2__c Limit 1];
        TestBNF.Revenue_Analyst__c = TestLocalRA.id;
        upsert testBNF;
        Test.stopTest();
       }
    
   
    
}