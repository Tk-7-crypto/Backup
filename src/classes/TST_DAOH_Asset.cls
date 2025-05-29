@isTest
private class TST_DAOH_Asset {
    
    @testSetup
    static void dataSetup() {
        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        Insert listOfUser;
        
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Asset accAssas1 = new Asset();
        accAssas1.Name ='Test';
        accAssas1.AccountId = accCase.id;
        insert accAssas1;
        
    }
    
    @isTest
    static void testCheckForDuplicacy(){
        
        User serviceUser = [SELECT Id FROM User WHERE Profile.Name = 'Service User' AND IsActive = true LIMIT 1];
        Account acc =[Select id from Account limit 1];
        System.runAs(serviceUser){
            
            Test.startTest();
            try
            {
                Asset accAssase = new Asset();
                accAssase.Name ='Test';
                accAssase.AccountId = acc.id;
                insert accAssase;
            }
            catch(Exception ex){
                ex.getMessage();
            }
            test.stopTest();
            
            
        }
    }
    
    
    
}