@isTest
public class TST_DAOH_Contract_PRM {
    
    @testSetup
    static void dataSetup() {
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
            insert lstUsers;
        System.runAs(partnerUser){
            Account ac = new Account(name ='Acme1') ;
            ac.AccountCountry__c = 'BM' ;
            ac.CustomerSegment__c = 'GOVERNMENT';
            ac.Sub_Industry__c = 'STATE';
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
            Contract ctrMark = TST_PEP_TestDataFactory.createContract('Ctr000126', ac.Id, prodmarketing.Id);
            ctr.Parent_Contract_Number__c = 123;
            ctr.Ultimate_Parent_Contract_Number__c = 345;
            ctr.Agency_Program__c=agencyprog.Id;
            ctr.EndDate=Date.today(); 
            ctr.Renewal_Status__c='Renewed';
            ctr.Notification_Counter__c=1;
            ctr.Non_Standard_Contract__c = false;
            ctr.PRM_Contract_type__c = 'Agency Program SOW';
            
            insert ctr; 
            ctrMark.Renewal_Status__c='Time to Renew';
            ctrMark.Notification_Counter__c=1;
            ctrMark.Parent_Contract_Number__c = 123;
            ctrMark.Ultimate_Parent_Contract_Number__c = 345;
            ctrMark.Agency_Program__c = agencyprogMark.Id;
            ctrMark.PRM_Parent_Contract_Number__c=ctr.ContractNumber;
            ctrMark.Non_Standard_Contract__c = false;
            ctrMark.PRM_Contract_type__c = 'Agency Program SOW';
            insert ctrMark;
            // ctr.New_Contract_Number__c=ctrMark.ContractNumber;
            //update ctr;      
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
    
    @IsTest
    static void testUpdateParentContract() {
        Test.startTest();        
        Contract ctr = [SELECT Id, Product__c,Renewal_Status__c,Name FROM Contract WHERE Name = 'Oce Sales'];
        Contract ctr2 = [SELECT Id, Product__c, Name,ContractNumber FROM Contract WHERE Name = 'Oce Marketing'];
        ctr.New_Contract_Number__c=ctr2.ContractNumber;
        update ctr;
        ctr2.SOW_status__c='Signed';
        update ctr2;
        Test.stopTest();
        System.assertEquals('Renewed', ctr.Renewal_Status__c);
    }
    
    @IsTest
    static void testUpdateContract() {
        Test.startTest();        
        Contract ctr2 = [SELECT Id, Product__c, Name,ContractNumber,Renewal_Status__c FROM Contract WHERE Name = 'Oce Marketing'];
        ctr2.Notification_Counter__c=2;
        update ctr2;
        Test.stopTest();
        System.assertEquals('Time to Renew', ctr2.Renewal_Status__c);
    }
}