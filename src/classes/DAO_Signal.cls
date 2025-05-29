/**
 * This is Signal (Signal__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Signal extends fflib_SObjectDomain{
    
    /**
     * Constructor of this class
     * @params sObjectList List<Signal__c>
     */
    public Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
    public DAO_Signal(List<Signal__c> sObjectList){
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Signal(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Signal__c  trigger.
     * @return void
     */
    public override void onBeforeInsert(){
      DAOH_Signal.populateSignalUniqueId((List<Signal__c>)Records,null);
      DAOH_Signal.validateSignalFields((List<Signal__c>)Records,null);
    }  
    
    /**
    * This method is used for before update of the Signal__c  trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Signal.validateSignalFields((List<Signal__c>)Records,(Map<Id,Signal__c>) existingRecords);
    }
    
    /**
     * This method is used for after insert of the Signal__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Signal.synchronizeProjectEvents((List<Signal__c>)Records, null);
        DAOH_Signal.createDeliverable((List<Signal__c>)Records, null);
        DAOH_Signal.insertAuditLogOnUpdate((List<Signal__c>)Records, null);
        if(mulesoftSetting != null 
           && (mulesoftSetting.Is_Mulesoft_User__c 
               || !mulesoftSetting.Ignore_Validation_Rules__c))
        {
            DAOH_Signal.sendEmailNotification((List<Signal__c>)Records,null);
        }
    }
    
    /**
     * This method is used for after update of the Signal__c trigger.
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Signal.synchronizeProjectEvents((List<Signal__c>)Records, (Map<Id,Signal__c>) existingRecords);
        DAOH_Signal.createDeliverable((List<Signal__c>)Records, (Map<Id,Signal__c>) existingRecords);
        DAOH_Signal.insertAuditLogOnUpdate((List<Signal__c>)Records, (Map<Id,Signal__c>) existingRecords);
        DAOH_Signal.updtRltdPJEToUpdtReciepients((List<Signal__c>)Records, (Map<Id,Signal__c>) existingRecords);
        if(mulesoftSetting != null 
           && (mulesoftSetting.Is_Mulesoft_User__c 
               || !mulesoftSetting.Ignore_Validation_Rules__c))
        {
            DAOH_Signal.sendEmailNotification((List<Signal__c>)Records,(Map<Id,Signal__c>) existingRecords);
        }
    }
    
    /**
     * This method is used for after delete of the Signal__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Signal.insertAuditLog((List<Signal__c>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the Signal__c trigger.
     * @return void
     */ 
    public override void onAfterUnDelete() {
        DAOH_Signal.synchronizeProjectEvents((List<Signal__c>)Records, null);
        DAOH_Signal.insertAuditLog((List<Signal__c>)Records,'UNDELETE');
    } 
} 
