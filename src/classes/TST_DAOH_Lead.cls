/**
 * This test class is used to test all methods in opportunity trigger.
 * version : 1.0
 */ 
@isTest
private class TST_DAOH_Lead {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Lead_Country_Exception_Mapping__c lc = new Lead_Country_Exception_Mapping__c();
        lc.Name = 'USA';
        lc.ISO_Code__c = 'US';
        insert lc;
        Account newAccount = UTL_TestData.createAccount();
        newAccount.Website = 'www.testa.com';
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        insert testContact1;
        Profile p = [select id,Name from profile where name='PRM Community User' limit 1];
        User TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', isActive = true,
        emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='japnalocal@metacube1222dd.com');
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
        Lead testLead2 = UTL_TestData.createLead();
        testLead2.FirstName='TestName2';
        testLead2.Disposition__c = 'Marketing to Nurture';
        testLead2.Nurture_Detail__c = '3 months';
        testLead2.Country = 'USA';
        testLead2.Status='Not Started';
        insert testLead2;
    }
    
    /**
     * This test method used for insert lead records
     */ 
    static testMethod void testLeadInsert() {   
        List<Lead> leads = [SELECT Disposition__c, Disposition_Date__c, Nurture_Area__c, Nurture_Detail__c, Nurture_Detail_Other__c FROM Lead];
        
        for(Lead ld : leads) {
            if(ld.Disposition__c == 'Test Disposition') {
                //System.assertEquals(Date.today(), ld.Disposition_Date__c);
            } else {
                System.assertEquals(null, ld.Disposition__c);
                System.assertEquals(null, ld.Disposition_Date__c);
                System.assertEquals(null, ld.Nurture_Area__c);
                System.assertEquals(null, ld.Nurture_Detail__c);
                System.assertEquals(null, ld.Nurture_Detail_Other__c);
            }
        }
    }
    
    /**
     * This test method used for update lead records
     */ 
    static testMethod void testLeadUpdate() {   
        List<Lead> leads = [SELECT Disposition__c, Disposition_Date__c, Nurture_Area__c, Nurture_Detail__c, Nurture_Detail_Other__c FROM Lead];
        
        Test.startTest();
            for(Lead ld : leads) {
                if(ld.Disposition__c == 'Test Disposition') {
                    ld.Disposition__c = 'Test Update';
                    ld.Status= CON_PEP.S_PEP_LD_STATUS_REJECTED;
                    ld.Comment__c = 'test';
                    ld.Reason_Code__c = 'Other';
                    ld.Country = '';
                    ld.FirstName='Test Name';
                    ld.Status='Not Started';
                }
            }
            update leads;
        Test.stopTest();
        
        for(Lead ld : leads) {
            if(ld.Disposition__c == 'Test Update') {
                //System.assertEquals(Date.today(), ld.Disposition_Date__c);
            } else {
                System.assertEquals(null, ld.Disposition__c);
                System.assertEquals(null, ld.Disposition_Date__c);
                System.assertEquals(null, ld.Nurture_Area__c);
                System.assertEquals(null, ld.Nurture_Detail__c);
                System.assertEquals(null, ld.Nurture_Detail_Other__c);
            }
        }
    }
}