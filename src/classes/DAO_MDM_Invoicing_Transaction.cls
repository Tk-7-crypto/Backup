/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Contain override Methods to run for MDM_Invoicing_Transaction__c trigger
*/
public class DAO_MDM_Invoicing_Transaction extends fflib_SObjectDomain {
    
    public DAO_MDM_Invoicing_Transaction(List<MDM_Invoicing_Transaction__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_MDM_Invoicing_Transaction(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        DAOH_MDM_Invoicing_Transaction.updateSapContactFields((List<MDM_Invoicing_Transaction__c>)Records, null);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_MDM_Invoicing_Transaction.updateSapContactFields((List<MDM_Invoicing_Transaction__c>)Records, (Map<Id, MDM_Invoicing_Transaction__c>)existingRecords);
    }
    
}