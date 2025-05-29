/**
 * This is Credit Control Threshold trigger handler class.
 * version : 1.0
 */ 
public class DAO_CreditControlThreshold extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Credit_Control_Threshold__c>
     */
    public DAO_CreditControlThreshold(List<Credit_Control_Threshold__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CreditControlThreshold(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Credit Control Threshold trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_CreditControlThreshold.validateSuperCreditControlGroup((List<Credit_Control_Threshold__c>)records);
    }
    
    /**
     * This method is used for before update of the Credit Control Threshold trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_CreditControlThreshold.validateSuperCreditControlGroup((List<Credit_Control_Threshold__c>)records);
    }

    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
    } 
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_CreditControlThreshold.validateSuperCreditControlGroup((List<Credit_Control_Threshold__c>)records);
    } 
    
}