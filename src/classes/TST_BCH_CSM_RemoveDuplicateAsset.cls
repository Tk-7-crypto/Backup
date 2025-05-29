@isTest
private with sharing class TST_BCH_CSM_RemoveDuplicateAsset {
    @TestSetup
    static void dataSetup(){
        List<Account> accList = new List<Account>();
        Account accountObject = UTL_TestData.createAccount();
        accountObject.Asset_Checked__c = false ;
        accList.add(accountObject); 
        Account accountObject1 = UTL_TestData.createAccount();
        accountObject1.Asset_Checked__c = false ;
        accList.add(accountObject1);
        insert accList;
        Contact contactObject =  new Contact(FirstName = 'TestName', Email ='Abcy@gmail.com' , LastName = 'TestContact', accountId = accountObject.id);
        insert contactObject;
        List<Asset> assetList = new List<Asset>();
        Asset assetObject = new Asset();
        assetObject.Name = 'Asset 1';
        assetObject.ContactId = contactObject.id;
        assetObject.AccountId = accountObject.Id;
        assetList.add(assetObject);
        insert assetObject;
        Asset assetObject1 = new Asset();
        assetObject1.Name = 'Asset 2';
        assetObject1.ContactId = contactObject.id;
        assetObject1.AccountId = accountObject.Id;
        assetList.add(assetObject1);
        insert assetObject1;
        Case caseObject = UTL_TestData.createCase();
        caseObject.AssetId = assetObject.id;
        caseObject.AccountId = accountObject.Id;
        caseObject.SuppliedEmail = 'Abcy@gmail.com';
        insert caseObject;
        
    }
    
    static testMethod void testBCHCRMOpportunityStageBatch() {
        List<Account> accList;
        accList = [SELECT Id FROM Account WHERE Asset_Checked__c = false ORDER BY Createddate ASC];
        System.assertEquals(2, accList.size()); 
        Test.startTest();
        BCH_CSM_RemoveDuplicateAsset batchOppStage = new BCH_CSM_RemoveDuplicateAsset();
        Database.executeBatch(batchOppStage);
        Test.stopTest();
        //System.assertEquals(1, oppStageList.size()); 
    }
    
}