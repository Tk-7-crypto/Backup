/**
* Created by Ronak Mehta on 16-Nov-2023
* Description : This Apex class is selector layer for Drug Product Name Object.
*/
public class SLT_DrugProductName  extends fflib_SObjectSelector{
    
    /************constructor************/
    public SLT_DrugProductName(){
        super(true, true, true);
    }
    
    /************param constructor************/
    public SLT_DrugProductName(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /************Method used to get field list of sobject************/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> { Drug_Product_Name__c.Id, Drug_Product_Name__c.Opportunity__c};
            }
    
    /************Method used to set up type of sobject************/
    public Schema.SObjectType getSObjectType(){
        return Drug_Product_Name__c.sObjectType;
    }
    
    /**
     * This Method Used to get Opportunity Drug Products by Condition
     * @params Set<Id> OppIdSet
     * @return List<Drug_Product_Name__c>
     **/
    public List<Drug_Product_Name__c> getOppDrugProductByOppId(Set<Id> OppIdSet, Set<String> fieldSet){
        return (List<Drug_Product_Name__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Opportunity__c in :OppIdSet').toSOQL());
        
    }
}