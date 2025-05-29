/*
* Version       : 1.0
* Description   : This test class is used for Select Territory
*/
@isTest
private class TST_SLT_Territory {
    
    @testSetup
    static void dataSetup() {
        list<Territory2Model> terModel = [Select Id From Territory2Model Where Name = 'Total Business Units'];
        Id terModelId = terModel[0].Id;
        
        list<Territory2Type> terType   = [SELECT id, DeveloperName from Territory2Type limit 1];
        Id terTypeId = terType[0].id;
        
        list<Territory2> insertTerList = new list<Territory2>();
        
        Territory2 ter1 = new Territory2(name ='test@1', DeveloperName ='test545', Territory2TypeId = terTypeId, 
		Territory2ModelId = terModelId, Legacy_Id__c ='A1', Included_in_Custom_Sharing__c = true);
        
        insert ter1;
    }
    
    @isTest
    static void testGetTerritoryById(){
        LIst<Territory2> terList = [SELECT id, Name FROM Territory2 WHERE name = 'test@1'];
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'ParentTerritory2Id'};
        List<Territory2> checkTerList = new SLT_Territory().getTerritoryById(new Set<Id> { terList[0].Id }, fieldSet);
        Test.stopTest();
        System.assertEquals(terList[0].Id, checkTerList[0].Id);
        
    }
    
    @isTest
    static void testGetTerritory(){
        LIst<Territory2> terList = [SELECT id, Name FROM Territory2 WHERE name = 'test@1'];
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'ParentTerritory2Id'};
        List<Territory2> checkTerList = new SLT_Territory().getTerritory(fieldSet);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetTerritoryByParentId(){
        LIst<Territory2> terList = [SELECT id, Name, ParentTerritory2Id FROM Territory2 WHERE name = 'test@1'];
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'ParentTerritory2Id'};
        List<Territory2> checkTerList = new SLT_Territory().getTerritoryByParentId(fieldSet, new Set<Id> { terList[0].ParentTerritory2Id });
        Test.stopTest();
        System.assertEquals(terList[0].ParentTerritory2Id, checkTerList[0].ParentTerritory2Id);
        
    }
    
    @isTest
    static void testGetTerritoryByWhereCondtion(){
        LIst<Territory2> terList = [SELECT id, Name, ParentTerritory2Id, Included_in_Custom_Sharing__c FROM Territory2 WHERE name = 'test@1'];
        Test.startTest();
        String whereCondtion = 'Included_in_Custom_Sharing__c = true';
        Set<String> fieldSet = new set<String>{'Id','Included_in_Custom_Sharing__c'};
        List<Territory2> checkTerList = new SLT_Territory().getTerritoryByWhereCondtion(fieldSet, whereCondtion);
        Test.stopTest();
        System.assertEquals(terList[0].Included_in_Custom_Sharing__c, checkTerList[0].Included_in_Custom_Sharing__c);
        
    }

}