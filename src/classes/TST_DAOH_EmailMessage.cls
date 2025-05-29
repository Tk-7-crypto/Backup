@isTest
private class TST_DAOH_EmailMessage {

    @testSetup
    static void dataSetup() {
        UTL_CSM_FLW_CompleteIRTMilestone.RequestEmailMessage rm = new UTL_CSM_FLW_CompleteIRTMilestone.RequestEmailMessage();
        Group g1 = new Group(Name='Q1', type='Queue');
        insert g1;
        QueuesObject q1 ;
        system.runAs(new User(id = UserInfo.getUserId())){
        q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        }
    	Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        CSM_ExternalClient_info__c bism = new CSM_ExternalClient_info__c(Name = 'BISM',Client_Url__c = 'BISM',Password__c = 'BISM',client_id__c='BISM',client_secret__c='BISM');
        insert bism;
        CSM_ExternalClient_info__c roche = new CSM_ExternalClient_info__c(Name = CON_CSM.S_ROCHE_SN,Client_Url__c = CON_CSM.S_ROCHE_SN,Password__c = CON_CSM.S_ROCHE_SN,client_id__c=CON_CSM.S_ROCHE_SN,client_secret__c=CON_CSM.S_ROCHE_SN);
        insert roche;
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
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
        
        Product2 p1 = UTL_TestData.createProduct();
        p1.Name = 'DDD';
        p1.SpecificToCSM__c = True;
        insert p1;
        
        Asset a1 = new Asset(Name = 'DDD', AccountId = acct.Id, Product2Id = p1.id);
        insert a1;
        
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'Nexxus MI';
        p2.SpecificToCSM__c = True;
        insert p2;
        
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a2;
        
        CSM_QI_Case_Categorization__c ccl = new CSM_QI_Case_Categorization__c();
        ccl.Product__c= p2.Id;
        ccl.SubType1__c = 'Incident-Module';
        ccl.SubType2__c = 'Formularies';  
        ccl.SubType3__c = '--none--';
        ccl.Active__c = true;
        ccl.Type__c = 'Categorization';
        ccl.Pillar__c = 'Information Offering';
        insert ccl;
        CSM_QI_Case_Categorization__c ccl2 = new CSM_QI_Case_Categorization__c();
        ccl2.Product__c= p1.Id;
        ccl2.SubType1__c = 'Incident-Module';
        ccl2.SubType2__c = 'Formularies';  
        ccl2.SubType3__c = '--none--';
        ccl2.Active__c = true;
        ccl2.Type__c = 'Categorization';
        ccl2.Pillar__c = 'Technology Solutions';
        insert ccl2;
        List<CSM_Email_To_Case_Custom_Settings__c> cmList = new List<CSM_Email_To_Case_Custom_Settings__c>();
        CSM_Email_To_Case_Custom_Settings__c cm = new CSM_Email_To_Case_Custom_Settings__c();
        cm.E2C_Address__c = 'caseContact@mail.com';
        //cm.RouteEmail__c = 'caseContact@mail.com';
        cm.Bypass_Route_Email__c = 'caseContact@mail.com';
        cm.CaseSource__c = 'Internal';
        cm.Categorization_Id__c = ccl2.Id;
        cm.Product_Id__c = p1.Id;
        cm.RecordTypeName__c = 'ActivityPlan';
        cm.SenderEmailToExclude__c = 'test@gmail.com';
        cm.Exclude_MessageList__c = false;
        cm.Keyword_Assignment__c = 'case;tsgd;compliance;utilization;resource planner;project planner;schedule by period;extension;';
        cmList.add(cm);
        CSM_Email_To_Case_Custom_Settings__c cm1 = new CSM_Email_To_Case_Custom_Settings__c();
        cm1.RecordTypeName__c = 'ActivityPlan';
        cm1.Type__c = 'Prevent Creation';
        cm1.Keyword_Assignment__c = 'case;tsgd;compliance;utilization;resource planner;project planner;schedule by period;extension;';
        cmList.add(cm1);
        insert cmList;
        CSM_Config_E2C_MessageList__c e2cList = new CSM_Config_E2C_MessageList__c();
        e2cList.Name = 'Out Of Office';
        e2cList.RecordTypeNames__c = 'DATACase, RandDCase, TechnologyCase, ActivityPlan';
        insert e2cList;
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Id RecordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        List<Case> cList = new List<Case>();
        Case c = new Case(
            Subject = 'TechnoCase 01',
            Description = 'Techno Case Description',
            AccountId = acct.Id
            , ContactId = con.Id
            , Origin = CON_CSM.S_EMAIL
            , Status = 'New'
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = 'Q1'
            , OwnerId = UserInfo.getUserId()
            , RecordTypeId = RecordTypeIdCase
            , CurrentQueue__c = queueUser.Id
        );
        c.TaskMilestone__c = 'prodops';
        c.Status = CON_CSM.S_IN_PROGRESS;
        c.SlaStartDate = System.now();
        cList.add(c);
        Case cc = new Case(
            Subject = 'TechnoCaseClosed 02',
            Description = 'Techno CaseClosed Description',
            AccountId = acct.Id
            , ContactId = con.Id
            , Origin = CON_CSM.S_EMAIL
            , Status = 'Closed'
            , AssignCaseToCurrentUser__c = false
            , InitialQueue__c = 'Q1'
            , OwnerId = UserInfo.getUserId()
            , RecordTypeId = RecordTypeIdCase
            , CurrentQueue__c = queueUser.Id
        );
        cc.SlaStartDate = System.now();
            cList.add(cc);
            Case c1 = new Case(
                Subject = 'R&D - Activity Plan Case 01',
            Description = 'R&D AP Case Description Closed',
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Email',
                Status = 'New',
                InitialQueue__c = 'group name',
                RandD_Location__c = 'Dalian',
                OwnerId = UserInfo.getUserId(),
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCaseRD,
                CurrentQueue__c = queueUser.Id
            );
        
        cList.add(c1);
        
        Case csData = new Case();
        csData.AccountId = acct.Id;
        csData.ContactId = con.Id;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.AssetId = a1.Id;
        csData.LOS__c = 'DATA';
        csData.CaseSubType1__c = 'DATA MGT/PRODUCTION';
        csData.CaseSubType2__c = 'DATA ISSUES';
        csData.CaseSubType3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
        csData.Priority = 'High';
        csData.Origin = 'Agent Initiated';
        csData.Subject = 'Data Test case';
        csData.Description = 'No information available';
        csData.Status = 'In Progress';
        csData.CurrentQueue__c = queueUser.Id;
        csData.InitialQueueData__c = queueUser.Id;
        csData.First_response_email_time__c = null;
        csData.AFU_TECH__c = true;
        cList.add(csData);
        
        Case e2cCase = new Case(
            Subject = 'Test E2C OOO Case',
            Description = 'R&D AP Case Description',
            AccountId = acct.Id,
            ContactId = con.Id,
            Origin = 'Email',
            Status = 'New',
            InitialQueue__c = 'group name',
            RandD_Location__c = 'Dalian',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCaseRD,
            CurrentQueue__c = queueUser.Id
        );
        cList.add(e2cCase);
        
        insert cList;
        
        List <CSMLiquidPlannerIntegration__c> csContactFieldList = new List<CSMLiquidPlannerIntegration__c>();
        CSMLiquidPlannerIntegration__c csContactFields = new CSMLiquidPlannerIntegration__c();
        csContactFields.Name = 'MIProductName';
        csContactFields.Product__c = 'DDD';
        csContactFields.Queue__c = 'testLastName';
        csContactFields.EmailAddress__c = 'test@testEmail.com';
        csContactFieldList.add(csContactFields);
        CSMLiquidPlannerIntegration__c csContactFieldProduct = new CSMLiquidPlannerIntegration__c();
        csContactFieldProduct.Name = 'DashboardProductName'; 
        csContactFieldProduct.Product__c = 'Dashboards (SFE/CBG)';
        csContactFieldProduct.Queue__c = 'Data AU BI Support';
        csContactFieldProduct.EmailAddress__c = 'test@testEmail.com';
        csContactFieldList.add(csContactFieldProduct);   
        insert csContactFieldList;
    }
    
    @isTest
    static void testUpdateCaseInboundTech(){
        Case caseRecord = [SELECT Id, Status, First_response_email_time__c, First_response_sent__c, Origin FROM Case WHERE Subject = 'TechnoCase 01' LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com',BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=true);
        Test.startTest();
        insert message;
        Test.stopTest();
    }
    
    static testmethod void testPreventEmailMessageDel(){
        Case c1 = [SELECT Id, Status,template__c FROM Case WHERE Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
            List<EmailMessage> newEmail = new List<EmailMessage>();
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'casecontact@mail.com', Subject = 'Test email RD Out', TextBody = '23456 ', ParentId = c1.Id)); 
        
            
            
            try{
                Test.startTest();
                c1.Status = 'Closed';
                update c1;
                insert newEmail;
                EmailMessage em = [Select FromAddress,Incoming,ToAddress,Subject,TextBody,ParentId,IsSendAsComment__c,Status From EmailMessage where Incoming = false Limit 1];
                    em.TextBody = 'Updated Text body';
                	em.IsSendAsComment__c = true;
                	em.Status = '3';
                    update em;
            }catch(DMLexception e){
                //system.assert(e.getMessage().contains('Cannot delete Email with related to Case'),'Cannot delete Email with related to Case');                       
            }
            Test.stopTest();
    }
    
    static testmethod void testPreventEmailMessageRandDDelIN(){
        Case c1 = [SELECT Id, Status,template__c FROM Case WHERE Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
        List<EmailMessage> newEmail = new List<EmailMessage>();
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = true, ToAddress= 'casecontact@mail.com', BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', Subject = 'Test email RD In', TextBody = '23456 ', ParentId = c1.Id)); 
            
            try{
                Test.startTest();
                c1.Status = 'Closed';
                update c1;
                insert newEmail;
                EmailMessage em = [Select FromAddress,Incoming,ToAddress,Subject,TextBody,ParentId From EmailMessage where Incoming = true Limit 1];
                
            }catch(DMLexception e){
            }
            Test.stopTest();
    }
    
    @isTest
    static void testMailSenderWhenEmailReceivedOnTechClosedCase(){
        Case c1 = [SELECT Id, Status,template__c FROM Case WHERE Status = 'Closed' and Subject = 'TechnoCaseClosed 02' LIMIT 1];
            List<EmailMessage> newEmail = new List<EmailMessage>();
        
        newEmail.add(new EmailMessage(FromAddress = 'shwetadxb@gmail.com', Incoming = true, ToAddress= 'shwetadxb@gmail.com', Subject = 'Test email Tech In', TextBody = '23456 ', ParentId = c1.Id)); 
        try{
             Test.startTest();
                insert newEmail;
            
            //DAOH_EmailMessage.MailSenderWhenEmailReceivedOnTechClosedCase(newEmail);
        }
        catch(Exception ex){
            ex.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseOnOutboundMail(){
        Case caseRecord = [SELECT Id, Status, First_response_email_time__c, First_response_sent__c, Origin FROM Case WHERE RecordTypeName__c='DATACase' AND First_response_email_time__c=NULL AND LOS__c='DATA' LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=False);
        Test.startTest();
        insert message;
        EmailMessage em = [Select FromAddress,Incoming,ToAddress,Subject,TextBody,ParentId,IsSendAsComment__c,Status From EmailMessage where Incoming = false Limit 1];
        em.TextBody = 'Updated Text body';
        em.IsSendAsComment__c = true;
		em.Status = '3';
        update em;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseOnOutboundMailtoBISMasComment(){
           Case caseRecord = [SELECT Id, Status, First_response_email_time__c, First_response_sent__c, Origin,Service_Now_Incident_Number__c,ServiceNowSystemType__c  FROM Case WHERE Subject = 'TechnoCase 01' LIMIT 1];
        caseRecord.Service_Now_Incident_Number__c = 'IQVIASRVC1';
        caseRecord.ServiceNowSystemType__c = 'IQVIA';
        caseRecord.External_System_Type__c = CON_CSM.S_ROCHE_SN;
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com',IsSendAsComment__c = true, ToAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=False, Status='3');
        Test.startTest();
         update caseRecord;
        insert message;
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseAutomedFollowUp(){

        Case caseRecord = [SELECT Id, Status, First_response_email_time__c, First_response_sent__c, Origin FROM Case WHERE RecordTypeName__c='DATACase' AND First_response_email_time__c=NULL AND LOS__c='DATA' LIMIT 1];
        caseRecord.Status = 'Closed';
        update caseRecord; 
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=true);
        Test.startTest();
        insert message;
        Test.stopTest();
        caseRecord = [select Id, CaseNumber, AFU_TECH__c from case where Id =: caseRecord.Id];
        /* System.assertEquals(false, caseRecord.AFU_TECH__c,'field is not updated');*/
    }
    
    @isTest
    static void testUpdateDeletedEmailAttachmentCountOnCase(){
        Case caseRecord = [SELECT Id, Status, Origin FROM Case WHERE RecordTypeName__c='ActivityPlan' AND Subject LIKE '%E2C OOO%' LIMIT 1];
        List<EmailMessage> messageList = new List<EmailMessage>();
        EmailMessage message1 = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'Chirag.chanana@gmail.com', Subject = 'Test subject for Out of Office',
                                                 BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=true);
        messageList.add(message1);
        EmailMessage message2 = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'Chirag.chanana@gmail.com', Subject = 'Test subject for Attachment',
                                                 BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com',TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=true);
        messageList.add(message2);
        insert messageList;
        Attachment attachment2 = new Attachment();
        attachment2.OwnerId = UserInfo.getUserId();
        attachment2.Name= 'sound.mp4';
        attachment2.ContentType = 'audio/mp4';
        attachment2.body= Blob.valueOf('Test music file attachment');
        attachment2.ParentId = message1.Id;
        insert attachment2;
        
        Test.startTest();
        delete messageList;
        Test.stopTest();
    }

    @IsTest
    static void testsenderEmailAddressBasedPrioritySet(){
        CSM_Case_Priority_and_E2C_Sender_Config__c custsettObj1 = new CSM_Case_Priority_and_E2C_Sender_Config__c();
        custsettObj1.Name = 'Email Sender 3';
        custsettObj1.E2C_Address__c = 'caseContact@mail.com';
        custsettObj1.Sender_Email_Address__c = 'dummyuser@mail.com';
        custsettObj1.Priority__c = 'Low';
        
        insert custsettObj1;
        Case caseRecord = [SELECT Id, Status, Origin FROM Case WHERE Subject='TechnoCase 01'  LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = ' Replytocsm@iqvia.com', Subject = 'Test subject for Out of Office',
                                                BccAddress  = 'casecontact@mail.com',CcAddress = ' Replytocsm@iqvia.com', TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=true);
        
        
        Test.startTest();
        insert message;
        Test.stopTest();
    }
    
    @isTest
    static void testCheckTagsInEmailMessageForCaseFields(){
        Group g1 = [SELECT id FROM Group WHERE Name='Q1' LIMIT 1];
        List<CSM_E2C_CaseTags__c> tagList = new List<CSM_E2C_CaseTags__c>();
        CSM_E2C_CaseTags__c tag1 = new CSM_E2C_CaseTags__c();
        tag1.Field_Label__c = 'Case Owner';
        tag1.Name = 'Case Owner';
        tag1.Field_API__c = 'OwnerId';
        tag1.RecordTypeNames__c = 'TechnologyCase';
        tagList.add(tag1);
        CSM_E2C_CaseTags__c tag2 = new CSM_E2C_CaseTags__c();
        tag2.Field_Label__c = 'Environment Type';
        tag2.Name = 'Environment Type';
        tag2.Field_API__c = 'EnvironmentType__c';
        tag2.RecordTypeNames__c = 'TechnologyCase';
        tagList.add(tag2);
        CSM_E2C_CaseTags__c tag3 = new CSM_E2C_CaseTags__c();
        tag3.Field_Label__c = 'Current Queue';
        tag3.Name = 'Current Queue';
        tag3.Field_API__c = 'CurrentQueue__c';
        tag3.RecordTypeNames__c = 'TechnologyCase';
        tagList.add(tag3);
        
        insert tagList;
        
        Group grp = new Group();
        grp.Name = 'Tech Q1';
        grp.DeveloperName = 'Tech_Q1';
        insert grp;
        
        Queue_User_Relationship__c queue = new Queue_User_Relationship__c();
        queue.Name = 'Q1';
        queue.QueueName__c = 'Q1';
        queue.Type__c = 'Queue'; 
        insert queue;
        
        Case caseRecord = [SELECT Id, Status, Origin FROM Case WHERE Subject='TechnoCase 01'  LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject for case tags in email',
                                                TextBody = 'This is test message <-Case Owner->: <"Tech Q1"> <-Environment Type->: <"Production"> <-Current Queue->: <"Q1">', ParentId = caseRecord.Id, Incoming=true);
        
        Test.startTest();
        insert message;
        Test.stopTest();
    }
 
        
    @isTest
    static void testimproveQ1CaseCreation(){
        String testLbl = Label.Replytocsm_Email;
        String testLbl1 = Label.Q1_Owner_Id;
        system.debug(logginglevel.error,testLbl);
        Group g1 = [SELECT id FROM Group WHERE Name='Q1' LIMIT 1];
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Contact con =  new Contact(FirstName = 'TestFirstName', Email ='vinaymauryably@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        
        List<Id> caseIds = new List<Id>();
        List<String> address = new List<String>();
        List<Case> cases = new List<Case>();
        Case caseObj = new Case();
        caseObj.OwnerId = testLbl1 ;
        caseObj.AccountId = newAccount.id;
        caseObj.ContactId = con.id;
        caseObj.SuppliedEmail = 'chirag@gmail.com';
        address.add(caseObj.SuppliedEmail);
        cases.add(caseObj);
        insert cases;
        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage emailObj = new EmailMessage();
        emailObj.fromName = 'Magulan Duraipandian'; // from name 
        emailObj.subject = 'This is the Subject!'; // email subject 
        emailObj.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body 
        emailObj.ParentId = caseObj.id ;
        emailObj.Incoming = true;
        emailObj.ToAddress = testLbl;
        insert emailObj;
    }
    
    @isTest
    static void testSetDescriptionFieldBlankForEmailToCase(){
        CSM_QI_EmailToCaseRouting__c emailToRouting = new CSM_QI_EmailToCaseRouting__c();
        emailToRouting.Name = 'testFromEmailToCase@gmail.com';
        emailToRouting.R_D_Enable_E2C_Description__c = false;
        insert emailToRouting;
        
       	Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Contact con =  new Contact(FirstName = 'TestFirstName', Email ='testContact@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        
        User user = UTL_TestData.createUser('system administrator', 1)[0];
        user.LastName = 'System';
        insert user;
       
        System.runAs(user){
            Case caseObj = new Case();
            caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
            caseObj.OwnerId = Label.Q1_Owner_Id;
            caseObj.Subject = 'TestingCaseDescriptionToBlank';
            caseObj.AccountId = newAccount.id;
            caseObj.ContactId = con.id;
            caseObj.SuppliedEmail = 'test@gmail.com';
            caseObj.From_EmailToCase__c = 'testFromEmailToCase@gmail.com';
            caseObj.Description = 'This is a test description';
            caseObj.Origin = 'Email';
            insert caseObj;
            
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.fromName = 'Text XYZ'; 
            emailMessage.subject = 'This is the Subject!';
            emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body 
            emailMessage.ParentId = caseObj.id ;
            emailMessage.Incoming = true;
            emailMessage.FromAddress = 'testFromAddress@gmail.com';
            insert emailMessage;
        }
    }
    @isTest
    static void teststopDuplicateCaseCreationinToAddress(){  
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com',CcAddress='casecontact@mail.com', Subject = 'Test subject',TextBody = 'Test dummy body',Incoming = true);
        Test.startTest();
        insert message;
        Test.stopTest();
    }
} 