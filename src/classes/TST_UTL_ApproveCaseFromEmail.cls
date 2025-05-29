/*
* Version       : 1.0
* Description   : This test class is used for UTL_ApprovecaseByEmail
*/
@isTest
private class TST_UTL_ApproveCaseFromEmail {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void setup() {
        UTL_TestData.createOneKeyConfig();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        List<Case> listOfCase = new List<Case>();
        listOfCase.add(UTL_TestData.createCase());
        insert listOfCase;
    }
	
    @IsTest    
    static void testIfCaseIsRejected() 
    {  
        Case resultCase = [SELECT Id, caseNumber FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        Contact cont = new Contact(firstName='john', lastName='smith', Email='test@test.com', HasOptedOutOfEmail=false);
        email.subject = 'Test Contact Email';
        email.plainTextBody = 'Reject this mail require long text, for case and this is , Number: '+resultCase.caseNumber+' test1234 this mail require long text';
        
        env.fromAddress = 'test@test.com';
        Test.startTest();
            UTL_ApproveCaseFromEmail obj= new UTL_ApproveCaseFromEmail();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
		
        resultCase = [SELECT Id, caseNumber,Status FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
       
    }
    
    @IsTest 
    static void testIfCaseIsApproved() 
    {   
        Case resultCase = [SELECT Id, caseNumber FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        Contact cont = new Contact(firstName='john', lastName='smith', Email='test@test.com', HasOptedOutOfEmail=false);
        insert cont ;
        email.subject = 'Test Contact Email';
        email.plainTextBody = 'Approve this mail require long text, for case and this is , Number: '+resultCase.caseNumber+' test1234 this mail require long text';
        env.fromAddress = 'test@test.com';
        Test.startTest();
            UTL_ApproveCaseFromEmail obj= new UTL_ApproveCaseFromEmail();
            obj.handleInboundEmail(email, env );
        Test.stopTest();
		
        resultCase = [SELECT Id, caseNumber,Status FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
       
    }
}