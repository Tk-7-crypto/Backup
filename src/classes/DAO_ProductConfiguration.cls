/**
 * This is Product Configuration trigger handler class.
 * version : 1.0 
 */
public class DAO_ProductConfiguration extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<Apttus_Config2__ProductConfiguration__c>
     */
    public DAO_ProductConfiguration(List<Apttus_Config2__ProductConfiguration__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ProductConfiguration(sObjectList);
        }
    }

    /**
     * This method is used for after update of the Product Configuration trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_CPQ_TS_ProductConfiguration.setProposalFieldsFromFinalizedCart(
            new Map<Id,Apttus_Config2__ProductConfiguration__c>((List<Apttus_Config2__ProductConfiguration__c>) Records),
            (Map<Id,Apttus_Config2__ProductConfiguration__c>) existingRecords);
    }
}