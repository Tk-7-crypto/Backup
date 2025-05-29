@isTest
public class TST_DAOH_TPA_Additional_Term {

	
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
        
        TPA_Additional_Term__c tpaAddTermForParent = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c = tpaRequest.Id,Term_Name__c='term name',Category__c='General Ad-Hoc Term',Use_Name__c='test use',Country_of_Offering__c='Canada',Primary_Offering_Name__c='primaryoffering',Secondary_Offering_Name__c='secoffering',Addtional_Term__c='test term',Exhibit_Attached__c=true,TPA_Legal_Entity_1__c = LegalEntities[0].Id);
        insert tpaAddTermForParent;
        tpaAddTermForParent = [Select Id FROM TPA_Additional_Term__c WHERE CurrencyIsoCode LIKE 'IN%'];
        for(Integer i=0;i<3;i++){
            TPA_Additional_Term__c tpaAddTerm = new TPA_Additional_Term__c(CurrencyIsoCode='INR',TPA_Request__c	= tpaRequest.Id,Term_Name__c='term name',Category__c='General Ad-Hoc Term',Use_Name__c='test use',Country_of_Offering__c='Canada',Primary_Offering_Name__c='primaryoffering',Secondary_Offering_Name__c='secoffering',Addtional_Term__c='test term',Exhibit_Attached__c=true,TPA_Legal_Entity_1__c = LegalEntities[i+1].Id);
            
            additionalTerms.add(tpaAddTerm);
        }
		additionalTerms[0].Parent_Additional_Terms__c = tpaAddTermForParent.Id;
		additionalTerms[2].Is_All_Legal_Entities_Selected__c = true;
        additionalTerms[2].TPA_Legal_Entity_1__c = null;
        insert additionalTerms;
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(TPA_Additional_Term__c=additionalTerms[1].Id,Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id);
        insert comRev;

        tpaAddTermForParent.Parent_Additional_Terms__c = additionalTerms[1].Id;
        update tpaAddTermForParent;
        return additionalTerms;
    }
    
    static testMethod void testDeleteOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
        Test.StartTest();
        delete additionalTerms;
        Test.StopTest();
		TPA_Additional_Term__c tpaAddTerm = [SELECT Id,Parent_Additional_Terms__c FROM TPA_Additional_Term__c WHERE Id =: additionalTerms[0].Parent_Additional_Terms__c];
    	System.assertEquals(null, tpaAddTerm.Parent_Additional_Terms__c);
    }
    
    static testMethod void testInsertOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
        TPA_Request__c tpaReq = [Select Id,Manual_Trigger_Reasons__c,Pending_Acknowledgements__c from TPA_Request__c Limit 1];
        DAOH_TPA_Additional_Term.addManualReviewReason(tpaReq,'test review');
        DAOH_TPA_Additional_Term.addPendingAck(tpaReq,'test pending');
    }
    
    static testMethod void testUpdateOperation(){
        List<TPA_Additional_Term__c> additionalTerms = generateTestData();
    	additionalTerms[0].Term_Name__c = 'test term2';
        additionalTerms[0].Category__c = 'Use Specific Ad-Hoc Terms';
        additionalTerms[0].Use_Name__c = 'test use2';
        additionalTerms[0].Primary_Offering_Name__c = 'test offering';
        additionalTerms[0].Secondary_Offering_Name__c = 'test sec offering';
        additionalTerms[0].Do_Not_Apply_if_Renewed__c = true;
        additionalTerms[0].Country_of_Offering__c = 'Japan';
        additionalTerms[0].Addtional_Term__c = 'test term3';
    	additionalTerms[0].CurrencyIsoCode = 'USD';
        additionalTerms[1].CurrencyIsoCode = 'USD';
        additionalTerms[2].CurrencyIsoCode = 'USD';
    	Test.StartTest();
        update additionalTerms;
        Test.StopTest();
    }
    
    

}