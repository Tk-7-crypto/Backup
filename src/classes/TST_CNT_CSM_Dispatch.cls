@isTest
public class TST_CNT_CSM_Dispatch {
    
    @testSetup
    static void dataSetup() {
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdCreate = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA CREATE Service').getRecordTypeId();               
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        accCase.AccountCountry__c = 'AL';
        insert accCase;
        Contact conCase = new Contact();
        conCase.AccountId = accCase.Id;
        conCase.FirstName = 'Saurabh';
        conCase.LastName = 'Sharma';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        insert conCase;
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queueUser1.QueueName__c ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queueUser1.Type__c ='User';
        queueUser1.ByPassedRestrictFormTier__c = true;
        queueUser1.User__c = UserInfo.getUserId();
        queueUser1.Group_Id__c = '00G6A000000nXKABCD';
        insert queueUser1;
        
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queueUser2.QueueName__c ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queueUser2.Type__c ='User';
        queueUser2.User__c = '0056A000002b6rKQAQ';
        queueUser2.Group_Id__c = '00G6A000000nXKABCD';
        insert queueUser2;
        
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'Nexxus MI';
        p2.SpecificToCSM__c = True;
        insert p2;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c();
        cc.Product__c= p2.Id;
        cc.SubType1__c = 'Incident-Module';
        cc.SubType2__c = 'Formularies';  
        cc.SubType3__c = '--none--';
        cc.Active__c = true;
        cc.Pillar__c = 'Information Offering';
        insert cc;
        Asset a3 = new Asset(Name = 'Nexxus MI', AccountId = accObjId, Product2Id = p2.id, Status ='Installed');
        insert a3;
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queues1.QueueName__c ='Q1'+CON_CSM.S_PRODOPS+'T3';
        queues1.RestrictFromTier__c = 'T2';
        queues1.RestrictFromQueues__c = 'Q1';
        queues1.ByPassedRestrictFormTier__c = false;
        queues1.Type__c ='Queue';
        queues1.Group_Id__c = '00G6A000000nXKABCD';
        insert queues1;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Tech CA TechSupport OK T2a';
        queues2.QueueName__c ='Tech CA TechSupport OK T2a';
        queues2.RestrictFromQueues__c = 'Q1';
        queues2.ByPassedRestrictFormTier__c = false;
        queues2.Type__c ='Queue';
        insert queues2;
        Case cs = new Case();
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Medium';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'In Progress';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.AssetId = a3.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs.Previous_Queue__c ='Tech CA TechSupport OK T2a';
        cs.PreviousQueueUser__c ='Tech CA TechSupport OK T2a';
        cs.Previous_User__c = UserInfo.getName();
        insert cs;
        cs.OwnerId = '00G6A000000nXKqUAM';
        cs.CurrentQueue__c = queues1.id;
        update cs;
        
        Case csData = new Case();
        csData.ContactId = conObjId;
        csData.AccountId = accObjId;
        csData.AssignCaseToCurrentUser__c = false;
        csData.OwnerId = UserInfo.getUserId();
        csData.RecordTypeId = recordTypeIdCreate;
        csData.Priority = 'Medium';
        csData.Origin = 'Customer Portal';
        csData.Mail_CC_List__c = 'nodata@info.com';
        csData.Subject = 'DATA Create  Test case';
        csData.Description = 'Test class to check case creation ';
        csData.Status = 'New';
        csData.CurrentQueue__c = queues1.Id;
        csData.AssetId = a3.Id;
        csData.Case_CategorizationId__c = cc.Id;
        csData.ProductName__c= 'Nexxus MI';
        csData.SubType1__c = 'Incident-Module';
        csData.SubType2__c = 'Formularies';  
        csData.SubType3__c = '--none--';
        csData.Previous_Queue__c ='Tech CA TechSupport OK T2a';
        insert csData;
        TimeSheet__c tsData = new TimeSheet__c();
        tsData.Status__c = 'Stop';
        tsData.Case__c = csData.id;
        tsData.Comment__c = 'Status changed';
        tsData.Type__c = 'Manual';
        tsData.Timeinhours__c = 0.01;
        insert tsData;
        csData.OwnerId = '0056A000002b6rKQAQ';
        csData.CurrentQueue__c = queues1.id;
        update csData;
    }
    @isTest
    static void testFetchRecords() {
        
        User user_1;
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername2@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            EmployeeNumber= '070707071',
            LanguageLocaleKey = 'en_US',
            Article_Manager__c = true,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'
        );
        insert user_1;
        Test.startTest();
        CNT_CSM_Dispatch.fetchRecords('User', 'FirstName', 'First');
        Test.stopTest();
    }
    @isTest
    static void testGetIdFromQueue() {
        Test.startTest();
        Queue_User_Relationship__c queuesList;
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        queuesList =[ select id ,Name,Group_Id__c from Queue_User_Relationship__c where Id =:queues1.Id limit 1];
        
        CNT_CSM_Dispatch.getIdFromQueue(queuesList.Group_Id__c);
        Test.stopTest();
    }
    
    @isTest
    static void testGetIdFromUser() {
        Test.startTest();
        User user_1;
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername3@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            EmployeeNumber= '070707072',
            Article_Manager__c = true,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'
        );
        insert user_1;
        
        User userQueue =[Select id,Name from User where Id =:user_1.Id];
        CNT_CSM_Dispatch.getIdFromUser(userQueue.Name);
        Test.stopTest();
    }
    @isTest
    static void testGetStatusPicklist() {
        case cs = [Select id from case where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getStatusPicklist(cs.Id);
        Test.stopTest();
    }
    @isTest
    static void testGetPreviousQueueBasedOnAssignee() {
        User user_1;
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername4@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            EmployeeNumber= '070707073',
            LanguageLocaleKey = 'en_US',
            Article_Manager__c = true,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'
        );
        insert user_1;
        
        User userQueue =[Select id,Name from User where Id =:user_1.Id];
        Test.startTest();
        CNT_CSM_Dispatch.getPreviousQueueBasedOnAssignee(userQueue.Name);
        Test.stopTest();
    }
    @isTest
    static void testGetCurrentStatus() {
        case c = [Select id from case  where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getCurrentStatus(c.id);
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetSubStatusValue() {
        Test.startTest();
        CNT_CSM_Dispatch.getPickListOptions('SubStatus__c');
        CNT_CSM_Dispatch.getSubStatusValue();
        Test.stopTest();
    }
    @isTest
    static void testGetSubStatusValueChange() {
        Test.startTest();
        CNT_CSM_Dispatch.getSubStatusValueChange('In Progress');
        CNT_CSM_Dispatch.getSubStatusValueChange('Awaiting');
        CNT_CSM_Dispatch.getSubStatusValueChange('Resolved with customer');
        Test.stopTest();
    }
    
    @isTest
    static void testgetPreviousUserValue() {
        Test.startTest();
        CNT_CSM_Dispatch.getPickListOptions('Previous_User__c');
        CNT_CSM_Dispatch.getPreviousUserValue();
        Test.stopTest();
    }
    
    @isTest
    static void testgetPreviousQueueValue() {
        case c = [Select id from case  where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getPreviousQueueValue(c.id);
        Test.stopTest();
    }
    @isTest
    static void testgetPreviousQueueAssignUser() {
        case c = [Select id from case  where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getPreviousQueueAssignUser(c.id,'Mathieu Thomas');
        Test.stopTest();
    }
    
    
    @isTest
    static void testgetOldCaseOwner() {
        case c = [Select id from case where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getOldCaseOwner(c.id);
        Test.stopTest();
    }
    @isTest
    static  void testgetOldCaseOwnerUser() {
        case c = [Select id from case where Subject = 'Techno Test case'];
        Test.startTest();
        CNT_CSM_Dispatch.getPreviousQueueBasedOnUser(c.id);
        CNT_CSM_Dispatch.getOldCaseOwnerUser(c.id);
        Test.stopTest();
    }
    
    @isTest
    static void testgetPickListOptions() {        
        Test.startTest();
        CNT_CSM_Dispatch.getPickListOptions('Status');
        Test.stopTest();
    }
    
    @isTest
    static void testSave() {
        Case c = [Select Status,ownerId,ProductName__c,Subtype1__c,Subtype2__c,PreviousQueueUser__c,Previous_User__c,Previous_Queue__c,Internal_Follow_Up__c,CaseNumber,CurrentQueue__c,CurrentQueue__r.RestrictFromQueues__c,CurrentQueue__r.RestrictFromTier__c,SubStatus__c,IsEscalated,TaskMilestone__c,RecordTypeName__c,SupportTier__c from case where Subject = 'Techno Test case'];
        CSM_Technology_Solutions_Form__c t = new CSM_Technology_Solutions_Form__c(Form_Type__c = 'OneKey New Field Request',Case__c = c.id, Troubleshooting_Status__c = 'wfdgfnf',Issue_description_Error_message__c = 'trsafdg',
            NumberOfEndUsersImpacted__c = 2,Online_or_AppVersion__c='Online Version',URL_incaseof_OnlineVersion__c='Test',Browser_Used__c='Opera',Incident_reproduced_in_Prod__c = 'Yes',
            User_login__c='fsgdhd',Project_Number__c = 'test');
            insert t;
        Test.startTest();
        //try{
            c.Internal_Follow_Up__c = System.now();
            c.Status = 'Awaiting';
            c.SubStatus__c = 'Customer Info';
            CNT_CSM_Dispatch.Save(c,c.id);
        //}catch(Exception e){
         //System.debug('exception e :'+ e.getMessage());
        //}
        Test.stopTest();
    }
    
    @isTest
    static void testSaveWithEsclationForm() {
        Case c = [Select Status,ownerId,ProductName__c,Subtype1__c,Subtype2__c,PreviousQueueUser__c,Previous_User__c,Previous_Queue__c,Internal_Follow_Up__c,CaseNumber,CurrentQueue__c,CurrentQueue__r.RestrictFromQueues__c,CurrentQueue__r.RestrictFromTier__c,SubStatus__c,IsEscalated,TaskMilestone__c,RecordTypeName__c,SupportTier__c from case where Subject = 'Techno Test case'];
        Test.startTest();
        try{
            CSM_Technology_Solutions_Form__c t = new CSM_Technology_Solutions_Form__c(Form_Type__c = 'T2toT3 Escalation',Case__c = c.id, Troubleshooting_Status__c = 'wfdgfnf',Issue_description_Error_message__c = 'trsafdg',
            NumberOfEndUsersImpacted__c = 2,Online_or_AppVersion__c='Online Version',URL_incaseof_OnlineVersion__c='Test',Browser_Used__c='Opera',Incident_reproduced_in_Prod__c = 'Yes',
            User_login__c='fsgdhd',Project_Number__c = 'test');
            insert t;
            CNT_CSM_Dispatch.Save(c,c.id);
        }catch(Exception e){
            System.debug('exception e :'+ e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void testgetAssignCurrentQueues(){
        Case c = [Select id from case Where OwnerId = '0056A000002b6rKQAQ'];
        Test.startTest();
        CNT_CSM_TakeOwnership.getAssignCurrentQueues(c.id);
        CNT_CSM_Dispatch.GetProfileName();
        CNT_CSM_Dispatch.readFieldSet('T2toT3','CSM_Technology_Solutions_Form__c');
        Test.stopTest();
    }
     @isTest
    static void testcheckUserFromCurrentQueue(){
        case c = [Select id from case Where OwnerId = '0056A000002b6rKQAQ'];
        Test.startTest();
        CNT_CSM_Dispatch.checkUserFromCurrentQueue(c.id);
        Test.stopTest();
    }
}
