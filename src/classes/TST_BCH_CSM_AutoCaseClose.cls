@isTest
private class TST_BCH_CSM_AutoCaseClose {
    @testSetup
    static void dataSetup() {
        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        listOfUser.add(UTL_TestData.createUser('System Administrator', 1)[0]);
        Insert listOfUser;
        
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct);
        
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        Study__c study= new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */
        Contact con = new Contact( FirstName = 'TestFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US');
        insert con;
        
        // cc list test data start
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.AccountCountry__c = 'US';
		accCase.CustomerSegment__c = 'GOVERNMENT';
		accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Contact conCase = new Contact();
        conCase.AccountId = accCase.Id;
        conCase.FirstName = 'Saurabh';
        conCase.LastName = 'Sharma';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        conCase.PreferredLanguage__c = 'en_US';
        conCase.Portal_Case_Type__c = 'Information Offering; Technology Solutions';
        conCase.Contact_User_Type__c = 'Rep User';
        insert conCase;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        
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

        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Product2 p1 = new Product2();
        p1.Name = 'DDD';
        p1.Pillar__c = 'Information Offering; Technology Solutions';
        p1.SpecificToCSM__c = True;
        insert p1;
        
        Asset a1 = new Asset(Name = 'DDD', AccountId = acct.Id, Product2Id = p1.id);
        insert a1;
        
        Product2 p2 = new Product2();
        p2.Name = 'Nexxus MI';
        p2.Pillar__c = 'Technology Solutions';
        p2.SpecificToCSM__c = True;
        insert p2;
        Product2 pd3 = new Product2();
        pd3.Name = 'Nexxus MI1';
        pd3.Pillar__c = 'Technology Solutions';
        pd3.SpecificToCSM__c = True;
        insert pd3;
        Product2 pd4 = new Product2();
        pd4.Name = 'DDM';
        pd4.Pillar__c = 'Technology Solutions';
        pd4.SpecificToCSM__c = True;
        insert pd4;
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a2;
        
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Product__c= p2.Id;
        cc.SubType1__c = 'Incident-Module';
        cc.SubType2__c = 'Formularies';  
        cc.SubType3__c = '--none--';
        cc.Active__c = true;
        cc.Type__c = 'Categorization';
        cc.Pillar__c = 'Information Offering';
        insert cc;
        Asset a3 = new Asset(Name = 'Nexxus MI', AccountId = accObjId, Product2Id = pd3.id, Status ='Installed');
        insert a3;
        Asset a4 = new Asset(Name = 'DDM', AccountId = accObjId, Product2Id = pd4.id, Status ='Installed');
        insert a4;
        
        Case cs = new Case();
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
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
        cs.AssetId = a3.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        caseList.add(cs);
        
        Case csData = new Case();
        csData.AccountId = accObjId;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.AssetId = a4.Id;
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
        caseList.add(csData);
        
        Case cs2 = new Case();
        cs2.ContactId = conObjId;
        cs2.AccountId = accObjId;
        cs2.AssignCaseToCurrentUser__c = false;
        cs2.OwnerId = UserInfo.getUserId();
        cs2.RecordTypeId = recordTypeIdTechno;
        cs2.Priority = 'Priority 4';
        cs2.Origin = 'Partner Portal';
        cs2.Mail_CC_List__c = 'nodata@info.com';
        cs2.Subject = 'Techno case';
        cs2.Description = 'Test class to check case creation';
        cs2.Status = 'Resolved with Customer';
        cs.AssetId = a3.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs2.CurrentQueue__c = queueUser1.Id;
        caseList.add(cs2);
        
        Case csTech1 = new Case();
        csTech1.ContactId = conObjId;
        csTech1.AccountId = accObjId;
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
        csTech1.AssetId = a3.Id;
        csTech1.Case_CategorizationId__c = cc.Id;
        csTech1.ProductName__c= 'Nexxus MI';
        csTech1.SubType1__c = 'Incident-Module';
        csTech1.SubType2__c = 'Formularies';  
        csTech1.SubType3__c = '--none--';
        csTech1.Case_Type__c = 'Problem';
        caseList.add(csTech1);
        
        // cc list test data end
        Study__c study1= CSM_Util.createStudy(acct2.Id);
        study1.Name ='STUDY12';
        study1.StudyID__c ='PROJ0012';
        study1.LabProjectCode__c ='LABPROJ0012';
        insert study1;
        Product2 product1 = CSM_Util.createProduct2();
        product1.Name = 'Nexxus MI5';
        product1.Pillar__c = 'Information Offering; Technology Solutions';
        insert product1;
        Asset aset1 = CSM_Util.createAsset('Nexxus MI5',product1.Id,acct.Id,con.Id,study1.Id);
        insert aset1;
                
        BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent1 = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'R&D',
                                          BusinessHoursId = bHours1.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        
                
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = study1.Id,Investigator_Name__c = con.Id,Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        Case cs1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'Resolved',
            Subject = 'Child Activity Plan Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent1.Id,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs1);
        
        Test.startTest();
        insert caseList;
        Test.stopTest();
        
    
    }
    
    static testMethod void testAutoCaseClose() 
    {
        Test.startTest();
        List<Case> caseList = Database.query('select Id,CaseNumber,Status,RecordTypeName__c,LastModifiedDate,Los__c,SubType1__c,SubStatus__c,CaseSource__c,CurrentQueue__r.Name,(Select Id, ParentId,CaseNumber, Status from Cases where ((Status not in (\'Waiting for\',\'Resolved\',\'Closed\',\'Abandoned\',\'Canceled\') and RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\')) OR (Status not in (\'Closed\',\'Abandoned\',\'Canceled\') and SubStatus__c != \'RCA Requested\' and RecordTypeName__c = \'TechnologyCase\'))) From Case');
        BCH_CSM_AutoCaseClose obj = new BCH_CSM_AutoCaseClose();
        obj.errors = new List<String>{'error1,error3,error4','error2'};
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null,caseList);
        obj.Finish(null);
        Test.stopTest();
    }
}