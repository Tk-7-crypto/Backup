@isTest
public class TST_CNT_GBL_SobjectSharingHandler {
    @testSetup
    static void dataSetup() {
		
        
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                                                              'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select id from Group limit 1];
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        territorySharing.Account_Country__c = 'AL';
        territorySharing.Maintenance_Job_Status__c = 'New';
        insert territorySharing;
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        sharingSetting.Child_Sharing_FieldSet_Name__c = 'SHR_Child_FieldSet';
        insert sharingSetting;
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
    }
    
    @isTest
    static void testFetchSobjectSharingRecords(){
        Test.startTest();
        list<Territory2Model> terModel = [Select Id From Territory2Model Where Name = 'Total Business Units'];
        Id terModelId = terModel[0].Id;
        
        list<Territory2Type> terType   = [SELECT id, DeveloperName from Territory2Type limit 1];
        Id terTypeId = terType[0].id;
        List<Territory2> terList = [select Id,Name,Sharing_Pillar__c,Leaf_Node__c from Territory2 where Legacy_Id__c ='AL'];
        list<Territory2> insertTerList = new list<Territory2>();
        if(terList.size() > 0){
            terList[0].Sharing_Pillar__c = CON_CRM.SHARING_PILLAR_GEOGRAPHY;
            terList[0].Leaf_Node__c = true;
            update terList;
            System.debug('--terList--'+terList);
        }else{
            Territory2 ter3 = new Territory2(name ='test@3', DeveloperName ='test547', Territory2TypeId = terTypeId, 
                                             Territory2ModelId = terModelId, Legacy_Id__c ='AL', Included_in_Custom_Sharing__c = true);
            insertTerList.add(ter3);
            insert insertTerList;
        }
        
        CNT_GBL_SobjectSharingHandler.fetchSobjectSharingRecords();
        Test.stopTest();
    }
    
    @isTest
    static void testsObjectSharingProcessedRecords(){
        Test.startTest();
        CNT_GBL_SobjectSharingHandler.sObjectSharingProcessedRecords();
        Test.stopTest();
    }
    
    @isTest
    static void testInitiateSobjectSharing(){
        Test.startTest();
        List<SObject_Sharing__c>  sobjectList = [select Id from SObject_Sharing__c];
        List<Territory_Sharing__c>  territoryList = [select Id from Territory_Sharing__c];
        System.debug('test query' + sobjectList);
        List<String> idList =  new  List<String>();
        for(SObject_Sharing__c sobj : sobjectList){
            idList.add((String)sobj.Id);
        }
        
        //
        CNT_GBL_SobjectSharingHandler.initiateSobjectSharing('allSharing', idList);
        //CNT_GBL_SobjectSharingHandler.initiateSobjectSharing('allTerritory',new List<String>{territoryList[0].Id});
        Test.stopTest();
    }
    /*
    @isTest
    static void testInitiateSobjectSharing() {
        Test.startTest();
        List<SObject_Sharing__c>  sobjectList = [select Id from SObject_Sharing__c];
         List<String> idList =  new  List<String>();
        for(SObject_Sharing__c sobj : sobjectList){
            idList.add((String)sobj.Id);
        }
         CNT_GBL_SobjectSharingHandler.initiateSobjectSharing('allSharing', idList);
        Test.stopTest();
    }*/
    
     @isTest
    static void testInitiateSobjectSharingWithTerritory() {
        Test.startTest();
        List<Territory_Sharing__c>  territoryList = [select Id from Territory_Sharing__c];
        System.debug('territory '  + territoryList);
         List<String> idList =  new  List<String>();
        for(Territory_Sharing__c TerList : territoryList){
            idList.add((String)TerList.Id);
        }
         Test.stopTest();
         CNT_GBL_SobjectSharingHandler.initiateSobjectSharing('allTerritory', idList);
       
    }
}