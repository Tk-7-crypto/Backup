public class DAO_AmaAgreementDetail extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_AmaAgreementDetail(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_AmaAgreementDetail(sObjectList);
        }
    }
    
    /**
     * This method is used for before update of the AMA_Agreement_Detail__c trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_AmaAgreementDetail.onBeforeUpdate((List<AMA_Agreement_Detail__c>)Records, existingRecords.values(), new Map<Id, AMA_Agreement_Detail__c>((List<AMA_Agreement_Detail__c>)Records), (Map<Id, AMA_Agreement_Detail__c>)existingRecords);
        }
    }
    
    /**
     * This method is used for after update of the AMA_Agreement_Detail__c trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_AmaAgreementDetail.onAfterUpdate((List<AMA_Agreement_Detail__c>)Records, existingRecords.values(), new Map<Id, AMA_Agreement_Detail__c>((List<AMA_Agreement_Detail__c>)Records), (Map<Id, AMA_Agreement_Detail__c>)existingRecords);
        }
    }

}
