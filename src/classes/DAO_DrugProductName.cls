/**
 * Created by Ronak Mehta on 16-Nov-2023
 * Description : This is Drug_Product_Name__c trigger DAO class.
 */
public class DAO_DrugProductName extends fflib_SObjectDomain {
    
    /**
     * Constructor of class
     * @params sObjectList List<Drug_Product_Name__c>
     */
    public DAO_DrugProductName(List<Drug_Product_Name__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DrugProductName(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_DrugProductName.updateFields((List<Drug_Product_Name__c>)Records);
    }
    
    public override void onAfterInsert() {
        DAOH_DrugProductName.updateOpportunityRecord((List<Drug_Product_Name__c>)Records);
    }
    
    public override void onAfterDelete() {
        DAOH_DrugProductName.updateOpportunityRecord((List<Drug_Product_Name__c>)Records);
    }
}