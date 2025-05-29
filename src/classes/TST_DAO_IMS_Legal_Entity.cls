@isTest
public class TST_DAO_IMS_Legal_Entity {
	
    @testSetup
    static void setup(){
        TPA_Request__c tpaRequest;
        Contact tpaContact;
        Address__c testAccount;
        Address__c testClientAccount;
        
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        
        List<IMS_Legal_Entity__c> LegalEntities =  new List<IMS_Legal_Entity__c>();
        List<TPA_Additional_Term__c> additionalTerms = new List<TPA_Additional_Term__c>();

        for(Integer i=0 ; i<6 ; i++ ){
            IMS_Legal_Entity__c newIMSLegalEntity = new IMS_Legal_Entity__c(Name='Test ' + i,CurrencyIsoCode='INR',TPA_Request__c = tpaRequest.Id);	
            LegalEntities.add(newIMSLegalEntity);
        }
        insert LegalEntities;
        LegalEntities = [SELECT Id FROM IMS_Legal_Entity__c WHERE Name LIKE 'Test%'];
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c tpaAddTerm = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c	= tpaRequest.Id,TPA_Legal_Entity_1__c = LegalEntities[i].Id);
            
            additionalTerms.add(tpaAddTerm);
        }
		
        
        insert additionalTerms;

    }
    
    static testMethod void testDeleteOperation(){
        List<IMS_Legal_Entity__c> LegalEntities = [SELECT Id , Name FROM IMS_Legal_Entity__c WHERE Name LIKE 'Test%'];
        List<TPA_Additional_Term__c> relatedAdditionalTerms = [SELECT Id, Name,TPA_Legal_Entity_1__c FROM TPA_Additional_Term__c];
		
        Test.startTest();
        
        delete LegalEntities;

        Test.stopTest();
        LegalEntities = [SELECT Id , Name FROM IMS_Legal_Entity__c WHERE Name LIKE 'Test%'];
        System.assertEquals(0,LegalEntities.size());
    }


}