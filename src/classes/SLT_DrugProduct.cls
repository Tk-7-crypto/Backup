/**
* Created by Ronak Mehta on 23-OCT-2024
* Description : This Apex class is selector layer for Drug Product Object.
*/
public class SLT_DrugProduct extends fflib_SObjectSelector{
    
    /************constructor************/
    public SLT_DrugProduct(){
        super(true, true, true);
    }
    
    /************Method used to get field list of sobject************/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> { Drug_Product__c.Id, Drug_Product__c.International_Drug_Name__c, Drug_Product__c.Local_Drug_Name__c, Drug_Product__c.Molecule_Name__c};
            }
    
    /************Method used to set up type of sobject************/
    public Schema.SObjectType getSObjectType(){
        return Drug_Product__c.sObjectType;
    }
    
    /**
     * Method to return Avacare default drug product
     * @return List<Drug_Product__c>
     **/
    public List<Drug_Product__c> getAvacareDrugProduct(){
        String internationalName = 'ASSET AGNOSTIC (OTHERS)';
        return (List<Drug_Product__c>) Database.query(newQueryFactory(true).setCondition('International_Drug_Name__c = :internationalName and Status__c =\'Active\'').toSOQL());
    }
}