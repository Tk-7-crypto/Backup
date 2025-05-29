@isTest
public class TST_TGR_TPA_Additional_Term {
	
    static List<TPA_Additional_Term__c> generateTestData(){
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

        for(Integer i=0 ; i<4 ; i++ ){
            IMS_Legal_Entity__c newIMSLegalEntity = new IMS_Legal_Entity__c(Name='Test ' + i,CurrencyIsoCode='INR',TPA_Request__c = tpaRequest.Id);	
            LegalEntities.add(newIMSLegalEntity);
        }
        insert LegalEntities;
        LegalEntities = [SELECT Id FROM IMS_Legal_Entity__c WHERE Name LIKE 'Test%'];
        
        TPA_Additional_Term__c tpaAddTermForParent = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c = tpaRequest.Id,TPA_Legal_Entity_1__c = LegalEntities[0].Id);
        insert tpaAddTermForParent;
        tpaAddTermForParent = [Select Id FROM TPA_Additional_Term__c WHERE CurrencyIsoCode LIKE 'IN%'];
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c tpaAddTerm = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c	= tpaRequest.Id,TPA_Legal_Entity_1__c = LegalEntities[i+1].Id);
            
            additionalTerms.add(tpaAddTerm);
        }
		additionalTerms[0].Parent_Additional_Terms__c = tpaAddTermForParent.Id;
		additionalTerms[2].Is_All_Legal_Entities_Selected__c = true;
        additionalTerms[2].TPA_Legal_Entity_1__c = null;
        insert additionalTerms;
        tpaAddTermForParent.Parent_Additional_Terms__c = additionalTerms[1].Id;
        update tpaAddTermForParent;
        return additionalTerms;
    }
    
    static testMethod void testDeleteOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
        
        delete additionalTerms;
        
		TPA_Additional_Term__c tpaAddTerm = [SELECT Id,Parent_Additional_Terms__c FROM TPA_Additional_Term__c WHERE Id =: additionalTerms[0].Parent_Additional_Terms__c];
    	System.assertEquals(null, tpaAddTerm.Parent_Additional_Terms__c);
    }
    
    static testMethod void testInsertOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
        
    }
    
    static testMethod void testUpdateOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
    	additionalTerms[0].CurrencyIsoCode = 'USD';
        additionalTerms[1].CurrencyIsoCode = 'USD';
        additionalTerms[2].CurrencyIsoCode = 'USD';
    	
        update additionalTerms;
    }
    
    
}