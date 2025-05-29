@istest
Private class TST_DAO_Product {
    @testSetup
    static void dataSetup() {
        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        //listOfUser.add(UTL_TestData.createUser('System Administrator', 1)[0]);
        Insert listOfUser;
        
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Asset accAssase = new Asset();
        accAssase.Name ='Test';
        accAssase.AccountId = accCase.id;
        insert accAssase;
        
    }
    
    @isTest
    static void testCheckForDuplicacy(){
        
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account acc =[Select id from Account limit 1];
        System.runAs(serviceUser){
            Product2 accAssas1 = new Product2();
            accAssas1.Name ='Test';
            accAssas1.SpecificToCSM__c = true;
            accAssas1.Pillar__c ='Technology Solutions';
            insert accAssas1;
            Test.startTest();
            try
            {
                Product2 accAssase = new Product2();
                accAssase.Name ='Test';
                accAssase.SpecificToCSM__c = true;
                accAssase.Pillar__c ='Technology Solutions';
                insert accAssase;
            }
            catch(Exception ex){
                ex.getMessage();
            }
            try
            {
                Product2 accAssase2 = new Product2();
                accAssase2.Name ='Test';
                accAssase2.SpecificToCSM__c = false;
                accAssase2.Pillar__c ='Technology Solutions';
                insert accAssase2;
                Product2 aP3 = [select Id,SpecificToCSM__c,Name From Product2 where SpecificToCSM__c = false LIMIT 1];
                aP3.SpecificToCSM__c = true;
                update aP3;
            }
            catch(Exception ex){
                ex.getMessage();
            }
            test.stopTest();
            
            
        }
    }
    
    
    
}