/**
* Created by Ronak Mehta on 16-Nov-2023
* Description : Contain common Methods to support LWC componet: lwcCrmAutoCompleteSearch
*/
public with sharing class CNT_CRM_DrugProduct {
    
    /**
     * This Method to insert drug Product Name records
     * @params String productIds
     * @params String parentId
     * @return Boolean
     */
    @AuraEnabled(Cacheable = false)
    public static Boolean saveDrugProductRecords(String productIds, String parentId){
        List<Drug_Product_Name__c> listOfODP = new List<Drug_Product_Name__c>();
        if(productIds != null && productIds != ''){
            List<String> listOfDrugProductId = productIds.split(',');
            if(listOfDrugProductId != null && listOfDrugProductId.size() > 0){
                for(String DrugProdId: listOfDrugProductId ){
                    Drug_Product_Name__c odc = new Drug_Product_Name__c();
                    odc.Drug_Product__c = DrugProdId;
                    odc.Opportunity__c = parentId;
                    listOfODP.add(odc);
                }
            }
        }
        if(listOfODP != null && listOfODP.size() > 0){
            upsert listOfODP;
            return true;
        }
        return false;
    }
    
    
    /**
     * This Method to getexiesing drug Product value on Opportunity
     * @params String opportunityId
     * @return String
     */
    @AuraEnabled(Cacheable = false)
    public static String getOldDrugProductValue(String opportunityId){
        List<Drug_Product_Name__c> listOfODP = new SLT_DrugProductName().getOppDrugProductByOppId(new Set<Id>{opportunityId},new Set<String>{'Id'});
        if(listOfODP.size() > 0){
            return '';
        }else{
            Opportunity opp = new SLT_Opportunity().getOpportunityDetails(opportunityId, new Set<String> {'Id', 'Drug_Product_Name__c'});
            return opp.Drug_Product_Name__c;
        }
    }
    
}