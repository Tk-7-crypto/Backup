@isTest
public class TST_CSM_Case_E2CEmailAlert {
    @testSetup
    static void dataSetup() {
        List<CSM_E2C_Email_Alert__c> listOfEmailToCase = new list<CSM_E2C_Email_Alert__c>();
        CSM_E2C_Email_Alert__c newE2CAlert3 = new CSM_E2C_Email_Alert__c(Name = 'test3', Case_Record_Type__c = 'DATACase',Email_Template_Id__c = 'CSM DATA E2C Case Creation azsupport',
                                                                        Send_Email_Action__c = 'Creation E2C',Account_Country__c = 'AF');
        CSM_E2C_Email_Alert__c newE2CAlert = new CSM_E2C_Email_Alert__c(Name = 'test', Case_Record_Type__c = 'DATACase',Email_Template_Id__c = 'CSM DATA E2C Case Creation azsupport',
                                                                       Send_Email_Action__c = 'Creation E2C',Account_Country__c = 'US');
        CSM_E2C_Email_Alert__c newE2CAlert1 = new CSM_E2C_Email_Alert__c(Name = 'test1', Case_Record_Type__c = 'DATACase',Email_Template_Id__c = 'CSM DATA E2C Case Creation azsupport',
                                                                       Send_Email_Action__c = 'CreationE2C', From_Email_Address__c='test@gmail.com');
        CSM_E2C_Email_Alert__c newE2CAlert2 = new CSM_E2C_Email_Alert__c(Name = 'test2', Case_Record_Type__c = 'DATACase',Email_Template_Id__c = 'CSM DATA E2C Case Creation azsupport',
                                                                       Send_Email_Action__c = 'CreationE2C');
        listOfEmailToCase.add(newE2CAlert3);
        listOfEmailToCase.add(newE2CAlert);
        listOfEmailToCase.add(newE2CAlert1);
        listOfEmailToCase.add(newE2CAlert2);
        insert listOfEmailToCase;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.AccountCountry__c = 'AF';
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
        insert conCase;
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'Techno Portal' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Saurabh Sharma' LIMIT 1].Id;
        Queue_User_Relationship__c queueUser1=new Queue_User_Relationship__c();
        queueUser1.Name ='Q1';
        queueUser1.QueueName__c ='Q1';
        queueUser1.Type__c ='User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
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
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
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
        cs.CurrentQueue__c = queueUser1.Id;
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
    }
    
    @isTest
    static void testSendEmailToUser() {
        CSM_Case_E2CEmailAlert.requestEmail newrequestEmail= new CSM_Case_E2CEmailAlert.requestEmail();
        newrequestEmail.newCase = [Select Id, AccountCountry__c, From_EmailToCase__c, RecordTypeName__c, SuppliedEmail, ContactId, Contact.PreferredLanguage__c from Case limit 1];
        newrequestEmail.caseAction = 'Creation E2C';
        
        CSM_Case_E2CEmailAlert.sendEmailToUser(new List<CSM_Case_E2CEmailAlert.requestEmail> {newrequestEmail});
    }
    
    @isTest
    static void testSendEmailToUser1() {
        CSM_Case_E2CEmailAlert.requestEmail newrequestEmail= new CSM_Case_E2CEmailAlert.requestEmail();
        newrequestEmail.newCase = [Select Id, AccountCountry__c, From_EmailToCase__c, RecordTypeName__c, SuppliedEmail, ContactId, Contact.PreferredLanguage__c from Case limit 1];
        newrequestEmail.caseAction = 'CreationE2C';
        
        CSM_Case_E2CEmailAlert.sendEmailToUser(new List<CSM_Case_E2CEmailAlert.requestEmail> {newrequestEmail});
    }
	
}