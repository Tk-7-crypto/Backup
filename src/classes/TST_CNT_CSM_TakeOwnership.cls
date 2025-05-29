@isTest
public class TST_CNT_CSM_TakeOwnership {
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
        queueUser1.Name ='prodops Tech Global Product Support T3';
        queueUser1.QueueName__c ='prodops Tech Global Product Support T3';
        queueUser1.Type__c ='User';
        queueUser1.Tier__c = 'Tier 3';
        queueUser1.User__c = UserInfo.getUserId();
        queueUser1.Group_Id__c = '00G6A000000nXKABCD';
        insert queueUser1;
        
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='prodops Tech Global Product Support T3';
        queueUser2.QueueName__c ='prodops Tech Global Product Support T3';
        queueUser2.Type__c ='User';
        queueUser2.Tier__c = 'Tier 3';
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
        cc.Pillar__c = 'Technology Solutions';
        insert cc;
        Asset a3 = new Asset(Name = 'Nexxus MI', AccountId = accObjId, Product2Id = p2.id, Status ='Installed');
        insert a3;
        Queue_User_Relationship__c queues1=new Queue_User_Relationship__c();
        queues1.Name ='prodops Tech Global Product Support T3';
        queues1.QueueName__c ='prodops Tech Global Product Support T3';
        queues1.Type__c ='Queue';
        queues1.Tier__c = 'Tier 3';
        queues1.User__c = UserInfo.getUserId(); 
        queues1.Group_Id__c = '00G6A000000nXKABCD';
        insert queues1;
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
        cs.Status = 'New';
        cs.CurrentQueue__c = queues1.Id;
        cs.AssetId = a3.Id;
        cs.Case_CategorizationId__c = cc.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        cs.Previous_Queue__c ='Tech CA TechSupport OK T2a';
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
    static void testgetPickListOptions() {        
        Test.startTest();
        CNT_CSM_TakeOwnership.getPickListOptions('Status');
        Test.stopTest();
    }
     @isTest
    static void testGetCurrentStatus() {
        case c = [Select id from case where Subject='Techno Test case'];
        Test.startTest();
        CNT_CSM_TakeOwnership.getCurrentStatus(c.id);
        Test.stopTest();
    }
     @isTest
    static void testGetStatusPicklist() {
        case caseRecord = [Select id from case where Subject='Techno Test case' limit 1];
        Test.startTest();
        CNT_CSM_TakeOwnership.getStatusPicklist(caseRecord.Id);
        CNT_CSM_TakeOwnership.getAssignCurrentQueues(caseRecord.Id);
        Test.stopTest();
    }
    @isTest
    static void testGetSubStatusValueChange() {
        Test.startTest();
        CNT_CSM_TakeOwnership.getSubStatusValueChange('In Progress');
        CNT_CSM_TakeOwnership.getSubStatusValueChange('Awaiting');
        CNT_CSM_TakeOwnership.getSubStatusValueChange('Resolved with customer');
        Test.stopTest();
    }
    @isTest
    static void testgetPreviousUserValue() {
        Test.startTest();
        CNT_CSM_TakeOwnership.getPickListOptions('Previous_User__c');
        //CNT_CSM_TakeOwnership.getPreviousUserValue();
        Test.stopTest();
    }
    @isTest
    static void testSave() {
        Case c = [Select Status,ownerId,PreviousQueueUser__c,AssignCaseToCurrentUser__c,Previous_User__c,Previous_Queue__c,CaseNumber,CurrentQueue__c,SubStatus__c,Internal_Follow_Up__c,IsEscalated from case where Subject='Techno Test case'];
        Test.startTest();
        c.Status = 'In Progress';
        c.Internal_Follow_Up__c = System.now();
        c.SubStatus__c = 'CIO';
        CNT_CSM_TakeOwnership.Save(c,c.id);
        Test.stopTest();
    } 
    
    @isTest
    static void testcheckUserFromCurrentQueue(){
        case c = [Select id from case Where OwnerId = '0056A000002b6rKQAQ'];
        Test.startTest();
        CNT_CSM_TakeOwnership.checkUserFromCurrentQueue(c.id);
        Test.stopTest();
    }
}
