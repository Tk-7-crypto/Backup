@isTest 
public class TST_CNT_PEP_SendToDocusign {   
    
    @testSetup 
    static void dataSetup() {
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;
        System.runAs(partnerUser){
        Account ac = new Account(name ='Acme1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'US' ;
        insert ac; 
        
        List<Product2> prodList = new List<Product2>();
        List<Agency_Program__c> agencyprogramList = new List<Agency_Program__c>();
        List<Contract> contractList = new List<Contract>();
        
        Product2 prod = TST_PEP_TestDataFactory.createProduct('Oce Sales');
        Product2 prodmarketing = TST_PEP_TestDataFactory.createProduct('Oce Marketing');
        prodList.add(prod);
        prodList.add(prodmarketing);
        Insert prodList;
        
        Agency_Program__c agencyprog = TST_PEP_TestDataFactory.createAgencyProgram(prod);
        agencyprog.Duration_in_month__c=6;
        Agency_Program__c agencyprogMark = TST_PEP_TestDataFactory.createAgencyProgram(prodmarketing);
        agencyprogramList.add(agencyprog);
        agencyprogramList.add(agencyprogMark);
        insert agencyprogramList;
        
        
        Contract ctr = TST_PEP_TestDataFactory.createContract('Ctr000125', ac.Id, prod.Id);
        ctr.Agency_Program__c=agencyprog.Id;
        ctr.EndDate=Date.today();
        ctr.Renewal_Status__c='Renewed';
        Contract ctrMark = TST_PEP_TestDataFactory.createContract('Ctr000126', ac.Id, prodmarketing.Id);
        ctrMark.Renewal_Status__c='Renewed';
        contractList.add(ctr);
        contractList.add(ctrMark);
        insert contractList;
            
        PEP_DocuSign_credentials__c docuSignCredentials = new PEP_DocuSign_credentials__c();
        docuSignCredentials.PSO_Team_Mailbox__c = 'xyz@abcz.com';
        docuSignCredentials.PSO_TeamLead_Email__c = 'xyz@abcz.com';
        insert docuSignCredentials;
            
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            Agency_Program_Financials__c apf=new Agency_Program_Financials__c();
            apf.RecordTypeId=agencyProgramFinancialsPrice;
            apf.Program_Name__c=agencyprog.Id;
            apf.Country__c='US';
            apf.CurrencyIsoCode='USD';
            apf.Default__c=true;
            apf.Product__c=prod.Id;
            apf.Price__c=100;
            insert apf;  
            
            Agency_Program_Financials__c apf2=new Agency_Program_Financials__c();
            apf2.RecordTypeId=agencyProgramFinancialsPrice;
            apf2.Program_Name__c=agencyprog.Id;
            apf2.Country__c='US';
            apf2.CurrencyIsoCode='USD';
            apf2.Default__c=false;
            apf2.Product__c=prod.Id;
            apf2.Price__c=100;
            insert apf2; 
            
        }
    }
    
     static Account getTestAccount() {
        Account testAccount=new Account(
            Name='Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Customer_Account').getRecordTypeId());
         return testAccount; 
    }
    
    
    static Contract getTestContract() {
        Contract testContract = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                          RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                          //AccountId=testAccount.Id,
                                          Status='Assigned - Not Started',
                                          Date_Tracking_started__c=Date.newInstance(2019, 12, 9),
                                          Date_executed_signed_contract_received__c = Date.newInstance(2019, 12, 9),
                                          PRM_Contract_type__c='Master Agency Agreement');
        
        return testContract;
    }
    
    
    static testmethod void SendNow_WithRestTest(){
       
        Account testAccount= getTestAccount();
        Contract testContract = getTestContract(); 
        
        CNT_PEP_SendToDocusign.testContract =new list<Contract>{testContract};
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpResponseGenerator());
        String result;
        Test.startTest();
        	result=CNT_PEP_SendToDocusign.SendNow_WithRest(True, testContract.Id, '1c78eee1-0897-4f1e-b4ee-418c2cf34f72');
        Test.stopTest();
        
        System.assertEquals(True, CNT_PEP_SendToDocusign.envelopeCreationSuccess,'Envelope Creation callout failed!!'); 
        
    }   
    
    
    public class TST_MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }    
}