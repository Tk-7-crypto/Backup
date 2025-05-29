@isTest
private class TST_Lead_FLW_PEP_LeadEmailAlert {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Account newAccount = UTL_TestData.createAccount();
        newAccount.Website = 'www.testa.com';
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        insert testContact1;
        Profile p = [select id,Name from profile where name='PRM Community User' limit 1];
        User TestUser1  = new User(alias = 'jpusr', email='japnalocal123@metacube.com', isActive = true,
        emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='japnalocal@metacube12222dd.com');
        TestUser1.ContactId = testContact1.Id;
        insert TestUser1;
        Lead testLead1 = UTL_TestData.createLead();
        testLead1.Disposition__c = 'Test Disposition';
        testLead1.Country = 'Afghanistan';
        testLead1.Lead_Score__c = '12';
        testLead1.LeadSource = 'Partner referral';
        testLead1.TECH_Partner_Account__c = newAccount.Id;
        testLead1.FirstName='Test Name';
        testLead1.Status='Not Started';
        testLead1.Email='rachit.nagar@metacube.com';
        System.runAs(TestUser1){
            testLead1.Status = 'Not Started';
            insert testLead1;
        }
    }
    
    /**
     * This test method used for insert lead records
     */ 
    static testMethod void testLeadInsert() {   
        List<Lead> leads = [SELECT TECH_Alliance_Manager__c,Status FROM Lead];
        
        for(Lead ld : leads) {
            if(ld.Status == 'Not Started') {
            } else {
                System.assertEquals(null, ld.Status);    
            }
        }
    }
    
    /**
     * This test method used for update lead records
     */ 
    static testMethod void testLeadUpdate() {   
        List<Lead> leads = [SELECT TECH_Alliance_Manager__c,Status FROM Lead];
        
        Test.startTest();
            for(Lead ld : leads) {
                if(ld.Status != 'Not Started' && ld.TECH_Alliance_Manager__c!=Null) {
                    ld.Disposition__c = 'Test Update';
                    ld.Status= CON_PEP.S_PEP_LD_STATUS_REJECTED;
                    ld.Comment__c = 'test';
                    
                    
                }
            }
            update leads;
        Test.stopTest();
        
        
    }
}