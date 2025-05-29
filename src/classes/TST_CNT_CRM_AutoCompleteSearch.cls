@isTest
public class TST_CNT_CRM_AutoCompleteSearch {
    
    @isTest
    public static void testFindRecords(){
        Drug_Product__c DrugProduct = UTL_TestData.createDrugProducts();
        insert DrugProduct;
        
        Test.startTest();
        List<sobject> result = CNT_CRM_AutoCompleteSearch.findRecords('','Drug_Product__c', 'International_Drug_Name__c', 'Name, International_Drug_Name__c', '30');
        System.assertEquals(true,result.size() > 0);
        result = CNT_CRM_AutoCompleteSearch.findRecords('Molecule_Name','Drug_Product__c', 'International_Drug_Name__c', 'Name, International_Drug_Name__c', '30');
        Test.stopTest();
    }
}