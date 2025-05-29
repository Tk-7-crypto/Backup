@isTest
private class TST_Case_CSM_CSAT_Flow_All_RecordType {
    
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
        
        Queue_User_Relationship__c t2=new Queue_User_Relationship__c();
        t2.Name ='T2';
        t2.QueueName__c ='T2';
        t2.Type__c ='Queue';
        t2.User__c = UserInfo.getUserId(); 
        insert t2;
        Queue_User_Relationship__c tu2=new Queue_User_Relationship__c();
        tu2.Name ='T2';
        tu2.QueueName__c ='T2';
        tu2.TECH_QueueUser__c = t2.Id;
        tu2.Type__c ='User';
        tu2.User__c = UserInfo.getUserId();
        insert tu2;
        
        Queue_User_Relationship__c q1 = new Queue_User_Relationship__c();
        q1.Name = 'Data Global E-Service';
        q1.QueueName__c = 'Data Global E-Service';
        q1.Type__c = 'Queue';
        q1.User__c = UserInfo.getUserId(); 
        insert q1;
        
        Queue_User_Relationship__c qu1 = new Queue_User_Relationship__c();
        qu1.Name = 'Data Global E-Service';
        qu1.QueueName__c = 'Data Global E-Service';
        qu1.Type__c = 'User';
        qu1.User__c = UserInfo.getUserId();
        insert qu1;
        
        List<Case> caseList = new List<Case>();

        Id conObjIdB = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATBFirstName testCSATBSetupContact' LIMIT 1].Id;
        Id conObjIdC = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATCFirstName testCSATCSetupContact' LIMIT 1].Id;
        Id conObjIdD = [SELECT Id, Name FROM Contact WHERE Name = 'MalliR Reddy' LIMIT 1].Id;
        Id conObjIdE = [SELECT Id, Name FROM Contact WHERE Name = 'TestCSATEFirstName testCSATESetupContact' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Product2 p2 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        Product2 pd3 = new Product2(Name = 'ComPAS',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert pd3;
        Product2 pd4 = new Product2(Name = 'DDM', Pillar__c = 'Information Offering',SpecificToCSM__c = True);
        insert pd4;
        
        
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(Product__c= p2.Id,SubType1__c = 'Incident-Module',
        SubType2__c = 'Formularies',SubType3__c = '--none--',Active__c = true,Type__c = 'Categorization',Pillar__c = 'Technology Solutions');
        insert cc;
        CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c(Product__c= pd4.Id,SubType1__c = 'DATA MGT/PRODUCTION',
        SubType2__c = 'DATA ISSUES',SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)',Active__c = true,Type__c = 'Categorization',Pillar__c = 'Information Offering');
        insert cc1;
        CSM_QI_Case_Categorization__c cc2 = new CSM_QI_Case_Categorization__c(Product__c= pd3.Id,SubType1__c = 'Incident-Module',
        SubType2__c = 'Formularies',SubType3__c = '--none--',Active__c = true,Type__c = 'Categorization',Pillar__c = 'Technology Solutions');
        insert cc2;
        Asset aD = new Asset(Name = 'Nexxus MI', AccountId = accObjIdD, Product2Id = p2.id, Status ='Installed');
        insert aD;
        Asset a4 = new Asset(Name = 'DDM', AccountId = accObjIdD, Product2Id = pd4.id, Status ='Installed');
        insert a4;
        Asset aB = new Asset(Name = 'Nexxus MI', AccountId = accObjIdB, Product2Id = p2.id, Status ='Installed');
        insert aB;
        Asset aC = new Asset(Name = 'ComPAS', AccountId = accObjIdC, Product2Id = pd3.id, Status ='Installed');
        insert aC;
        
        Asset aE = new Asset(Name = 'Nexxus MI', AccountId = accObjIdSpons, Product2Id = p2.id, Status ='Installed');
        insert aE;
        
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
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs.Force_CSAT_Email_Survey__c = true;
        cs.SLA_Policies__c = 'Code';
        cs.InitialQueue__c = 'T1';
        caseList.add(cs);
        
        Case ct2 = new Case();
        ct2.ContactId = conObjIdE;
        ct2.AccountId = accObjIdSpons;
        ct2.AssignCaseToCurrentUser__c = false;
        ct2.OwnerId = UserInfo.getUserId();
        ct2.RecordTypeId = recordTypeIdTechno;
        ct2.Priority = 'Priority 4';
        ct2.Origin = 'Customer Portal';
        ct2.Mail_CC_List__c = 'nodata@info.com';
        ct2.Subject = 'Techno Test case';
        ct2.Description = 'Test class to check case creation ';
        ct2.Status = 'Resolved with Customer';
        ct2.CurrentQueue__c = tu2.Id;
        ct2.ProductName__c= 'Nexxus MI';
        ct2.SubType1__c = 'Incident-Module';
        ct2.SubType2__c = 'Formularies';  
        ct2.SubType3__c = '--none--';
        ct2.Force_CSAT_Email_Survey__c = true;
        ct2.InitialQueue__c = 'T2';
        caseList.add(ct2);
        
        Case c = new Case();
        c.ContactId = conObjIdD;
        c.AccountId = accObjIdD;
        c.AssignCaseToCurrentUser__c = false;
        c.OwnerId = UserInfo.getUserId();
        c.RecordTypeId = recordTypeIdTechno;
        c.Priority = 'Priority 4';
        c.Origin = 'Customer Portal';
        c.Mail_CC_List__c = 'nodata@info.com';
        c.Subject = 'Techno Test case';
        c.Description = 'Test class to check case creation ';
        c.Status = 'Resolved with Customer';
        c.CurrentQueue__c = queueUser1.Id;
        c.ProductName__c= 'Nexxus MI';
        c.SubType1__c = 'Incident-Module';
        c.SubType2__c = 'Formularies';  
        c.SubType3__c = '--none--';
        c.Force_CSAT_Email_Survey__c = true;
        c.InitialQueue__c = 'T1';
        caseList.add(c);
        
        Case csData = new Case();
        csData.ContactId = conObjIdD;
        csData.AccountId = accObjIdD;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.LOS__c = 'DATA';
        csData.SubType1__c = 'DATA MGT/PRODUCTION';
        csData.SubType2__c = 'DATA ISSUES';
        csData.SubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
        csData.Priority = 'High';
        csData.Origin = 'Agent Initiated';
        csData.Subject = 'Data Test case';
        csData.Description = 'No information available';
        csData.Status = 'Resolved';
        csData.CurrentQueue__c = q1.Id;
        csData.InitialQueueData__c = q1.Id;
        csData.First_response_email_time__c = null;
        csData.First_response_sent__c = FALSE;
        csData.Force_CSAT_Email_Survey__c = true;
        caseList.add(csData);
        
        Case cs2 = new Case();
        cs2.ContactId = conObjIdB;
        cs2.AccountId = accObjIdB;
        cs2.AssignCaseToCurrentUser__c = false;
        cs2.OwnerId = UserInfo.getUserId();
        cs2.RecordTypeId = recordTypeIdTechno;
        cs2.Priority = 'Priority 4';
        cs2.Origin = 'Partner Portal';
        cs2.Mail_CC_List__c = 'nodata@info.com';
        cs2.Subject = 'Techno case';
        cs2.Description = 'Test class to check case creation';
        cs2.Status = 'Resolved with Customer';
        cs2.ProductName__c= 'Nexxus MI';
        cs2.SubType1__c = 'Incident-Module';
        cs2.SubType2__c = 'Formularies';  
        cs2.SubType3__c = '--none--';
        cs2.CurrentQueue__c = queueUser1.Id;
        cs2.Force_CSAT_Email_Survey__c = true;
        cs2.InitialQueue__c = 'T1';
        caseList.add(cs2);
        
        Case csTech1 = new Case();
        csTech1.ContactId = conObjIdC;
        csTech1.AccountId = accObjIdC;
        csTech1.AssignCaseToCurrentUser__c = false;
        csTech1.OwnerId = UserInfo.getUserId();
        csTech1.RecordTypeId = recordTypeIdTechno;
        csTech1.Priority = 'Priority 4';
        csTech1.Origin = 'Partner Portal';
        csTech1.Mail_CC_List__c = 'nodata@info.com';
        csTech1.Subject = 'Techno Test case for csh';
        csTech1.Description = 'Test class to check case creation ';
        csTech1.Status = 'Resolved with Customer';
        csTech1.CurrentQueue__c = queueUser1.Id;
        csTech1.ProductName__c= 'ComPAS';
        csTech1.SubType1__c = 'Incident-Module';
        csTech1.SubType2__c = 'Formularies';  
        csTech1.SubType3__c = '--none--';
        csTech1.Case_Type__c = 'Problem';
        csTech1.Force_CSAT_Email_Survey__c = true;
        csTech1.InitialQueue__c = 'T1';
        caseList.add(csTech1);
        
        // cc list test data end
        Study__c study1= CSM_Util.createStudy(accObjIdSpons);
        study1.Name ='STUDY12';
        study1.StudyID__c ='PROJ0012';
        study1.LabProjectCode__c ='LABPROJ0012';
        insert study1;

        BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent1 = new Entitlement(Name='Testing', AccountId=accObjIdB,Type = 'R&D',
                                          BusinessHoursId = bHours1.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        
                
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = study1.Id,Investigator_Name__c = conObjIdB,Site_Name__c = accObjIdB);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        Case cs1 = new Case(
            AccountId = accObjIdB,
            ContactId = conObjIdB,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'Resolved',
            Subject = 'Child Activity Plan Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'T1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent1.Id,
            Force_CSAT_Email_Survey__c = true,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs1);
        
        Test.startTest();
        insert caseList;
        Test.stopTest();
        
    
    }
    
    @isTest
    static void testCSATCaseClosed(){
        List<Case> caseList = Database.query('Select id,Status,CaseNumber,Force_CSAT_Email_Survey__c From Case where Status in (\'Resolved\',\'Resolved with Customer\')');
        for(Case c : caseList){
            c.status = 'Closed';
        }
        if(caseList != null && !caseList.isEmpty()){
            Test.startTest();
            update caseList;
            Test.stopTest();
            caseList = Database.query('Select id,Status,CaseNumber,Force_CSAT_Email_Survey__c From Case LIMIT 10');
            System.assertEquals('Closed', caseList[0].Status, 'Closed');
        }
    }

}