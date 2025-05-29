@isTest
private class TST_WSC_CSM_RnDCaseManagement {
    
    @isTest
    static void testRnDCaseManagement() {
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testRnDCaseManaSite',AccountCountry__c = 'IN',RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acct.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accList.add(acct);
        Account acct2 = new Account(Name = 'testRnDCaseManaSponsor', AccountCountry__c = 'IN', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acct2.C_SAT_Survey_Option__c = 'TS Option B;TS Option C;TS Option D;DATA Option B;DATA Option C;DATA Option D;R&D Option B;R&D Option C;R&D Option D;TS Option E';
        accList.add(acct2);
        insert accList;
        
        Study__c study= new Study__c(Name = 'testRnDCaseManagementStudy', Sponsor__c = acct2.Id,Protocol__c ='testRnDCaseManagementStudy');
        insert study;
        Contact con = new Contact( FirstName = 'TestRnDCaseManagementFirstName', Lastname='testRnDCaseManagementContact', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='testRnDCaseManagementcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        insert con;
        
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='RnD - Case RnDCaseManagement';
        queues1.Tier__c ='Tier 1';
        queues1.QueueName__c ='RnD - Case RnDCaseManagement';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='RnD - Case RnDCaseManagement';
        queueUser1.Tier__c ='Tier 1';
        queueUser1.QueueName__c ='RnD - Case RnDCaseManagement';
        queueUser1.TECH_QueueUser__c = queues1.Id;
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Los__c = 'IQVIA Clinical Trial Payments';
        cc.SubType1__c = 'Please Specify';
        cc.SubType2__c = 'Please Specify';  
        cc.SubType3__c = 'Please Specify';
        cc.Active__c = true;
        cc.Type__c = 'Categorization';
        cc.Pillar__c = 'R&D';
        insert cc;
        BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent1 = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'R&D',BusinessHoursId = bHours1.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)),EndDate=Date.valueof(System.now().addYears(2)));
        
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = con.Id,Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        Test.startTest();
        WSC_CSM_RnDCaseManagement.getStudyDetails('testRnDCaseManagementStudy');
        WSC_CSM_RnDCaseManagement.getContactDetails('testRnDCaseManagementcon@iqvia.com');
        WSC_CSM_RnDCaseManagement.createContact('test2','RndCaseM',acct.Id,'testRnDCaseMa1nagementcon@iqvia.com','en_US','USA');
        WSC_CSM_RnDCaseManagement.createContact('TestRnDCaseManagementFirstName','testRnDCaseManagementContact',acct.Id,'testRnDCaseManagementcon@iqvia.com','en_US','USA');
        WSC_CSM_RnDCaseManagement.getSponsorAccountDetails('testRnDCaseManaSponsor', 'IN');
        WSC_CSM_RnDCaseManagement.getSiteAccountDetails('testRnDCaseManaSite', 'IN');
        WSC_CSM_RnDCaseManagement.createStudy('PROT2024', acct2.Id, 'Active', 'Bridge','PROJ123','4325436364', 'inSite');
        WSC_CSM_RnDCaseManagement.updateStudy('PROT2024', 'PROJ123', '4325436364', 'inSite');
        WSC_CSM_RnDCaseManagement.createCase(con.Id, acct.Id,'Mallikarjuna Reddy','testRnDCaseManagementcon@iqvia.com','Test RnD CTP WSC', 'Test RnD CTP WSC', 'IQVIA Clinical Trial Payments','Please Specify','Low', null, 'RnD - Case RnDCaseManagement', study.Id, 'R&D - Clinical Trial Payment','CONTR001','INV001','SITE001','INVN001','VC001','InSite',null,null,null);
        Test.stopTest();
    }

}