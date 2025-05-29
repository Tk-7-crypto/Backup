/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalCaseHistory
 */
@isTest
private class TST_CNT_CSM_PortalCaseHistory {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent test',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john.test@acme.com',
            Portal_Case_Type__c = 'Information Offering',
            Contact_User_Type__c = 'HO User',
            AccountId = account.Id);
        insert contact;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        List<CSM_QI_Data_Portal_Queue_User_details__c> dts = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = account.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        dts.add(dT);
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = account.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        dts.add(dd);
        insert dts;
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
            User user = New User(Alias = 'com', Email = 'john.test@acme.com', IsActive = true, ContactId = contact.Id, ProfileId = profilId,
                                 Username = 'john.test@acme.com.csh', LastName = 'testLastName', CommunityNickname = 'testCommunityNicknameCSH', 
                                 TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
            insert user;
        }
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'DDD';
        p2.SpecificToCSM__c = True;
        Insert p2;
        Asset at = new Asset(Name='DDD', Product2Id = p2.Id, AccountId = account.Id);
        insert at;
        CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
        cc1.Product__c = p2.Id;
        cc1.Pillar__c = 'Information Offering';
        cc1.SubType1__c = 'DATA MGT/PRODUCTION';
        cc1.SubType2__c = 'DATA ISSUES';  
        cc1.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
        cc1.Active__c = true;
        Insert cc1;
        
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=qurPortal.Id,Current_Queue__c = 'Q1');
        insert c;
        List<CaseComment> ccList = new List<CaseComment>();
        CaseComment cc = new CaseComment(ParentId = c.Id, IsPublished=true,CommentBody='TestComment');
        ccList.add(cc);
        CaseComment cc2 = new CaseComment(ParentId = c.Id, IsPublished=true,CommentBody='ServiceNow Comment:New -- TestComment');
        ccList.add(cc2);
        insert ccList;
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = c.Id;
        ch.Field = 'Status';
        insert ch;
        EmailMessage em = new EmailMessage();
        em.status = '3';
        em.relatedToId = c.Id;
        em.fromAddress = 'sender@example.com';
        em.fromName = 'Jean Test'; // from name
        em.subject = 'This is the Subject!'; // email subject
        em.htmlBody = '<html><body><b><p>Hello abc@mailinator.com --------------- Original Message --------------- From:replytocsm@iqvia.com To:abc@mailinator.com<<p>Email message</p>/b></body></html>';
        String[] toIds = new String[]{UserInfo.getUserId()}; 
        em.toIds = toIds;
        insert em; 
        
        CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
        custsettObj2.Name = 'Org Wide No-Reply';
        custsettObj2.Setting_Type__c = 'Org Wide';
        custsettObj2.Other_Details__c = 'Customer Portal';
        custsettObj2.Origin__c = 'Customer Portal';
        
        CSM_Case_Details_Global_Setting__c custsettObj = new CSM_Case_Details_Global_Setting__c();
        custsettObj.Name = 'CAS_ET_CSM_AttachmentUpload';
        custsettObj.Setting_Type__c = 'Email Template';
        custsettObj.Other_Details__c = 'CAS_ET_CSM_AttachmentUploadNotification';
        custsettObj.Origin__c = 'Customer Portal';
        custsettObj.Component_Id__c = '0D26A000000L1W5';
        custsettObj.Country__c = CON_CSM.S_DEFAULT;
        insert new List<CSM_Case_Details_Global_Setting__c>{custsettObj2, custsettObj};
    }
    
    /**
     * This method used to get a List of CaseComment for a caseId
     */    
    @IsTest
    static void testGetCaseComments() {
        List<Case> c = new  List<Case>();
        List<CaseComment> ccList = new List<CaseComment>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        ccList = CNT_CSM_PortalCaseHistory.getCaseComments(c[0].Id);
        Test.stopTest();
        Integer expected = 2;
        Integer actual = ccList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get a List of CaseHistory for a caseId
     */    
    @IsTest
    static void testGetCaseHistory() {
        List<Case> c = new  List<Case>();
        List<CaseHistory> ch = new List<CaseHistory>();
        c = [SELECT id, Status FROM Case WHERE Subject = 'TestCase'];
        Set<String> fields = new set<String> ();
        fields.add('Status');
        fields.add('Priority');
        fields.add('Impact');
        fields.add('Urgency');
        Test.startTest();
        ch = CNT_CSM_PortalCaseHistory.getCaseHistory(c[0].Id, fields);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = ch.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get a List of EmailMessage for a caseId
     */    
    @IsTest
    static void testGetEmailMessages() {
        List<Case> c = new  List<Case>();
        List<EmailMessage> em = new List<EmailMessage>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        em = CNT_CSM_PortalCaseHistory.getEmailMessages(c[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = em.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get a List of CNT_CSM_PortalCaseHistory.CSM_CaseHistory for a caseId
     */    
    @IsTest
    static void testGetCSM_CaseHistory() {
        List<Case> c = new  List<Case>();
        List<CNT_CSM_PortalCaseHistory.CSM_CaseHistory> csm_ch = new List<CNT_CSM_PortalCaseHistory.CSM_CaseHistory>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
		ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c[0].Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        csm_ch = CNT_CSM_PortalCaseHistory.getCSM_CaseHistory(c[0].Id,'true','true');
        Test.stopTest();
        Integer expected = 5;
        Integer actual = csm_ch.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testInsertCaseComment() {
        List<Case> c = new  List<Case>();
        Test.startTest();
        c = [SELECT id,ContactId FROM Case WHERE Subject = 'TestCase'];
        CaseComment cc = new CaseComment(ParentId = c[0].Id, IsPublished=true,CommentBody='TestComment2');
        //Task tsk = new Task(WhatId = c[0].Id, WhoId = c[0].ContactId, Subject = 'test', Description ='Test Case for Task', TaskSubtype = 'Call', Status = 'Open', Priority ='High');
        //insert tsk;
        CNT_CSM_PortalCaseHistory.insertCaseComment(cc);
        CNT_CSM_PortalCaseHistory.getLogCalls(c[0].Id);
        Test.stopTest();
    }
    
    
    @IsTest
    private static void sendAttachmentEmailToCaseOriginator() {
        List<Asset> assets = new List<Asset>();
        Test.startTest();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Contact contact = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1];
        User user = [SELECT Id, Name FROM User WHERE Username = 'john.test@acme.com.csh' LIMIT 1];
        System.runAs(user) {
            Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            Queue_User_Relationship__c ff = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' LIMIT 1 ]; 
            
            Case cs = new Case();
            cs.ContactId = contact.Id;
            cs.AccountId = account.Id;
            cs.AssignCaseToCurrentUser__c = false;
            cs.OwnerId = UserInfo.getUserId();
            cs.RecordTypeId = recordTypeIdData;
            cs.Priority = 'Medium';
            cs.Origin = 'Customer Portal';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Portal Data Test case';
            cs.Description = 'Portal Data Test case';
            cs.Status = 'New';
            cs.RootCause__c = 'Access Request';
            cs.CurrentQueue__c = ff.Id;
            cs.Previous_Queue__c = 'Tech CA TechSupport OK T2a';
            cs.SubType1__c = 'DATA MGT/PRODUCTION';
            cs.SubType2__c = 'DATA ISSUES';  
            cs.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
            cs.Device__c = 'iPhone';
            cs.Resolution__c = 'test resolution';
            cs.CSM_QI_Data_Originator__c = user.Id;
            Insert cs;
            CNT_CSM_PortalCaseHistory.sendAttachmentEmailToCaseOriginator(cs.Id);
        }
        Test.stopTest();
    }

}