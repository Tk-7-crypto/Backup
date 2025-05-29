/**
* This is SAP_Contact Domain class.
* version : 1.0
*/
public class DAO_SAP_Contact extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<SObject>
    */
    public DAO_SAP_Contact(List<SObject> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_SAP_Contact(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the SAP_Contact trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
            DAOH_SAP_Contact.setSAPContactFields((List<SAP_Contact__c>)Records,null);
        }
    }
    
    /**
    * This method is used for before update of the SAP_Contact trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return  void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
            DAOH_SAP_Contact.setSAPContactFields((List<SAP_Contact__c>)Records,(Map<Id, SAP_Contact__c>)existingRecords);
        }
    }
    
    /**
    * This method is used for after update of the SAP_Contact trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return void
    */    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) { 
        if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
            DAOH_SAP_Contact.setSAPContactApprovalStatus((List<SAP_Contact__c>)Records, (Map<Id, SAP_Contact__c>)existingRecords); 
        }
    }
    
    
    /**
    * This method is used for after insert of the SAP_Contact trigger.
    * @return void
    */
    public override void onAfterInsert() {
        if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
            DAOH_SAP_Contact.setSAPContactApprovalStatus((List<SAP_Contact__c>)Records,null); 
        }
    }
}