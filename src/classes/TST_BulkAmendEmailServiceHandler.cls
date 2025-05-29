@isTest
public class TST_BulkAmendEmailServiceHandler {
    @testSetup
    static void setUpTestData() {
        Contact con = new Contact(FirstName = 'test', LastName = 'test', Email = 'test@test.com');
		insert con;
        
        Task tn = new Task(WhoId = con.id, Subject = 'test 123');
        insert tn;
        
        Apttus__APTS_Agreement__c amaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        amaAgreement.Name = 'Test AMA Agreement';
        amaAgreement.Apttus__Subtype__c = 'RX PHARMA or BIOTECH MANUFACTURER';
        amaAgreement.Number_Of_Records__c = 90000;
        amaAgreement.Sales_Rep_Count__c = 260;
        amaAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(System.Today().year(), 07, 12);
        amaAgreement.Apttus__Contract_End_Date__c = Date.newInstance(System.Today().year(), 07, 14);
        amaAgreement.Apttus__Primary_Contact__c = con.id;
        amaAgreement.Apttus__Auto_Renewal__c = true;
        insert amaAgreement;
        
        amaAgreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        amaAgreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        update amaAgreement;
        
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c(Name= CON_CLM.AMA_AMEND_TEMPLATE_NAME, Apttus__IsActive__c = true);
        insert template;   
    }
    
    public static testMethod void test_BulkAmendEmailServiceHandlerRenew(){
        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_RENEW +'\n'+'Test Task Description \n On Thu, Jul 21, 2022 at 3:45 PM IQVIA Global Contract Management ';
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }
    
    public static testMethod void test_BulkAmendEmailServiceHandlerChanges(){
        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_CHANGES;
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }

    public static testMethod void test_BulkAmendEmailServiceHandlerCancel() {
        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_CANCEL;
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }

    public static testMethod void test_BulkAmendEmailServiceHandlerNoContact() {
        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test_test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_RENEW;
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }

    public static testMethod void test_BulkAmendEmailServiceHandlerRenewWODesc(){
        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_RENEW;
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }

    public static testMethod void test_BulkAmendEmailServiceHandlerRenewNextYear(){
        Apttus__APTS_Agreement__c amaAgreement = [Select Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test AMA Agreement' LIMIT 1];
        amaAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(System.Today().year()+1, 07, 12);
        amaAgreement.Apttus__Contract_End_Date__c = Date.newInstance(System.Today().year()+1, 07, 14);
        amaAgreement.CLM_Event__c = 'Renewal';
        update amaAgreement;

        BulkAmendEmailServiceHandler obj = new BulkAmendEmailServiceHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = 'test@test.com';
        email.plainTextBody = CON_CLM.AMA_AMEND_ACTION_RENEW;
        
        Test.startTest();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }  
} 