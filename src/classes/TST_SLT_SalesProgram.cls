/*
* Version       : 1.0
* Description   : This test class is used for Select Sales_Program__c
*/
@isTest
public class TST_SLT_SalesProgram {
	@testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Sales_Program__c sp = UTL_TestData.createSalesProgram(acc.Id);
        insert sp;
    }
    
    @isTest
    static void testGetSalesProgramById() {
        Sales_Program__c sp = [SELECT id, Name FROM Sales_Program__c WHERE Name = 'Test Sales Program'];
        Set<String> spFieldSet = new Set<String> {'Id', 'Name'};
        Test.startTest();
        Map<Id, Sales_Program__c> idToSalesProgramMap = new SLT_SalesProgram().getSalesProgramById(new Set<Id> { sp.Id });
        Map<Id, Sales_Program__c> idToSalesProgramMap1 = new SLT_SalesProgram().getSalesProgramById(new Set<Id> { sp.Id }, spFieldSet);
        Test.stopTest();
        System.assertEquals(sp.Id, idToSalesProgramMap.get(sp.Id).Id);
        System.assertEquals(sp.Name, idToSalesProgramMap1.get(sp.Id).Name);
    }

     /**********************************************************************************************
    * @Author: Barkha Pandey
    * @Date: 17/10/2021
    * @Description: This method is responsible for covering selectBySearchString of SLT_SalesProgram.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    ***********************************************************************************************/    
     static testMethod void getSelectBySearchStringTest(){
        SLT_SalesProgram sltObjectClass = new SLT_SalesProgram();
        Id actId = [SELECT Id FROM Account LIMIT 1].Id;
        Sales_Program__c salesRec = [SELECT Id,Name FROM Sales_Program__c LIMIT 1];
        String searchString = salesRec.Name;
        String searchStr = '\'%' + searchString + '%\'';
        Set<String> fieldsToQuery = new Set<String>{'Id', 'Name'};
        List<Sales_Program__c> salesRecLst = sltObjectClass.selectBySearchString(searchStr, new Set<Id>{actId}, fieldsToQuery);
        System.assertEquals(salesRecLst[0].Name , salesRec.Name);
        System.assertEquals(salesRecLst[0].Id , salesRec.Id);
    }
}