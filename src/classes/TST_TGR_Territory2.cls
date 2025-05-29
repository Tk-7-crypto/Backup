/**
* This test class is used to test all methods in Territory2 trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Territory2 {
    @testSetup
    static void dataSetup() {
        
        list<Territory2Model> terModel = [Select Id From Territory2Model Where Name = 'Total Business Units'];
        Id terModelId = terModel[0].Id;
        
        list<Territory2Type> terType   = [SELECT id, DeveloperName from Territory2Type limit 1];
        Id terTypeId = terType[0].id;
        
        list<Territory2> insertTerList = new list<Territory2>();
        
        Territory2 ter1 = new Territory2(name ='test@1', DeveloperName ='test545', Territory2TypeId = terTypeId, 
                                         Territory2ModelId = terModelId, Legacy_Id__c ='A1', Included_in_Custom_Sharing__c = true, Sharing_Pillar__c ='SHR_TER');
        
        Territory2 ter2 = new Territory2(name ='test@2', DeveloperName ='test546', Territory2TypeId = terTypeId, 
                                         Territory2ModelId = terModelId, Legacy_Id__c ='A2', Included_in_Custom_Sharing__c = true, Sharing_Pillar__c ='SHR_TER');
        
        Territory2 ter3 = new Territory2(name ='test@3', DeveloperName ='test547', Territory2TypeId = terTypeId, 
                                         Territory2ModelId = terModelId, Legacy_Id__c ='A3', Included_in_Custom_Sharing__c = true);
        
        insertTerList.add(ter1);
        insertTerList.add(ter2);
        insertTerList.add(ter3);
        
        insert insertTerList;
        
        insertSObjectSharing();
    }
    
    @future
    private static void insertSObjectSharing(){
        SObject_Sharing__c sObjSharing = new SObject_Sharing__c(Enable_Sharing_Calculation__c =true, 
                                                                Parent_Sobject__c = 'Apttus__APTS_Agreement__c', Sharing_Territory_Label__c ='Opportunity');
        insert sObjSharing;
    }
    
    static testMethod void testTerritory2Update() {
        List<Territory2> updateTerList = new List<Territory2>();
        test.startTest();
        List<Territory2> terList = [Select Id,ParentTerritory2Id From Territory2 where Name like 'test@%' Order BY Name];
        System.debug('terList : '+terList);
        terList[0].ParentTerritory2Id = terList[1].Id;        	
        terList[2].Sharing_Pillar__c ='SHR_TER';
        updateTerList.add(terList[0]);
        updateTerList.add(terList[2]);
        update terList[2];
        test.stopTest();
    }

}