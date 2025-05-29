@isTest
private class TST_CSM_IQVIA_Macro_AssignToCurrentUser {
    @testSetup
    static void dataSetup() {
        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        listOfUser.add(UTL_TestData.createUser('System Administrator', 1)[0]);
        Insert listOfUser;
        
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestCSATSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        acct.C_SAT_Survey_Option__c = 'TS Option B;DATA Option B;R&D Option B';
        accList.add(acct);
        
        Account acct1 = new Account(Name = 'testSetupTestCSATSiteAccount2organon',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        acct1.C_SAT_Survey_Option__c = 'TS Option C;DATA Option C;R&D Option C';
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestCSATSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        acct2.C_SAT_Survey_Option__c = 'TS Option E';
        accList.add(acct2);
        // cc list test data start
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.C_SAT_Survey_Option__c = 'TS Option D;DATA Option D;R&D Option D';
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno PortalCSAT';
        accCase.RDCategorization__c = 'Site';
        accCase.AccountCountry__c = 'US';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        accList.add(accCase);
        insert accList;
        
        Id accObjIdB = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestCSATSiteAccount1' limit 1].Id;
        Id accObjIdC = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestCSATSiteAccount2organon' limit 1].Id;
        Id accObjIdD = [SELECT Id, Name FROM Account WHERE Name = 'Techno PortalCSAT' limit 1].Id;
        Id accObjIdSpons = [SELECT Id, Name FROM Account WHERE Name = 'testSetupTestCSATSponsorAccount1' limit 1].Id;
        
        /* Added End */
        List<Contact> conList = new List<Contact>();
        Contact conB = new Contact( FirstName = 'TestCSATBFirstName', Lastname='testCSATBSetupContact', Phone='(619)8152-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testBSetupcon@iqvia.com', AccountId = accObjIdB,PreferredLanguage__c = 'en_US');
        conList.add(conB);
        
        Contact conC = new Contact( FirstName = 'TestCSATCFirstName', Lastname='testCSATCSetupContact', Phone='(619)8532-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testCSetupcon@iqvia.com', AccountId = accObjIdC,PreferredLanguage__c = 'en_US');
        conList.add(conC);
        
        Contact conCase = new Contact();
        conCase.AccountId = accObjIdD;
        conCase.FirstName = 'MalliR';
        conCase.LastName = 'Reddy';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        conCase.PreferredLanguage__c = 'en_US';
        conCase.Portal_Case_Type__c = 'Information Offering; Technology Solutions';
        conCase.Contact_User_Type__c = 'Rep User';
        conList.add(conCase);
        
        Contact conE = new Contact( FirstName = 'TestCSATEFirstName', Lastname='testCSATESetupContact', Phone='(619)8532-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testESetupcon@iqvia.com', AccountId = accObjIdC,PreferredLanguage__c = 'en_US');
        conList.add(conE);
        
        insert conList;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='T1';
        queues1.QueueName__c ='T1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='T1';
        queueUser1.QueueName__c ='T1';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
        
        List<Case> caseList = new List<Case>();

        Id conObjIdB = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATBFirstName testCSATBSetupContact' LIMIT 1].Id;
        Id conObjIdC = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATCFirstName testCSATCSetupContact' LIMIT 1].Id;
        Id conObjIdD = [SELECT Id, Name FROM Contact WHERE Name = 'MalliR Reddy' LIMIT 1].Id;
        Id conObjIdE = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATEFirstName testCSATESetupContact' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Product2 p2 = new Product2();
        p2.Name = 'Nexxus MI';
        p2.Pillar__c = 'Technology Solutions';
        p2.SpecificToCSM__c = True;
        insert p2;
        
        
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Product__c= p2.Id;
        cc.SubType1__c = 'Incident-Module';
        cc.SubType2__c = 'Formularies';  
        cc.SubType3__c = '--none--';
        cc.Active__c = true;
        cc.Type__c = 'Categorization';
        cc.Pillar__c = 'Information Offering';
        insert cc;
        
        Asset aD = new Asset(Name = 'Nexxus MI', AccountId = accObjIdD, Product2Id = p2.id, Status ='Installed');
        insert aD;
        
        Case cs = new Case();
        cs.ContactId = conObjIdD;
        cs.AccountId = accObjIdD;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'Resolved with Customer';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.AssetId = aD.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs.Force_CSAT_Email_Survey__c = true;
        cs.SLA_Policies__c = 'Code';
        cs.InitialQueue__c = 'T1';
        caseList.add(cs);
        
        Test.startTest();
        insert caseList;
        Test.stopTest();
        
    
    }
    
    @isTest
    static void testCurrentQueueAssignment(){
        List<Case> caseList = Database.query('Select id,Status,AssignCaseToCurrentUser__c,CaseNumber,Force_CSAT_Email_Survey__c From Case where Status in (\'Resolved\',\'Resolved with Customer\')');
        for(Case c : caseList){
            c.AssignCaseToCurrentUser__c = true;
            update c;
        }
        System.debug(caseList[0].AssignCaseToCurrentUser__c + ' : '+caseList[0].Id);
        if(caseList != null && !caseList.isEmpty()){
            Test.startTest();
            update caseList;
            Test.stopTest();
            List<Case> caseList1 = Database.query('Select id,Status,AssignCaseToCurrentUser__c,CaseNumber,Force_CSAT_Email_Survey__c From Case Where Status in (\'Resolved\',\'Resolved with Customer\')');
            System.debug(caseList1);
            System.assertEquals(false, caseList1[0].AssignCaseToCurrentUser__c, 'True'); 
        }
    }
}