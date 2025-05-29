/**
 * This is Lead Domain class.
 * version : 1.0
 */
public class DAO_Lead extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */ 
    public DAO_Lead(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Lead(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Lead trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        updateInvalidEmailAddress(null);
        DAOH_Lead.setDispositionDate((List<Lead>)Records, null);
        DAOH_Lead.setFieldNullValues((List<Lead>)Records);
        DAOH_Lead.setUserIdForAllianceManager((List<Lead>)Records, null);
        DAOH_Lead.setLeadCountry((List<Lead>)Records, null);
        DAOH_Lead.setValidateWebsite((List<Lead>)Records, null);
        DAOH_Lead.setDefaultValuesforLSN((List<Lead>)Records);
    }

    /**
     * This method is used for after insert of the Lead trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Lead.sendNotifToManager((List<Lead>)Records, null);
    }


    /**
     * This method is used for after update of the Lead trigger.
     * @params Map<Id, SObject> existingRecords
     * @return void
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords){

        DAOH_Lead.sendNotifToManager((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.defineSharingRuleForPartner((List<Lead>)Records, (Map<Id, Lead>)existingRecords);

    }
    
    /**
     * This method is used for before update of the Lead trigger.
     * @params Map<Id, SObject> existingRecords
     * @return void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        updateInvalidEmailAddress(existingRecords);
        DAOH_Lead.setDispositionDate((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.setFieldNullValues((List<Lead>)Records);
        DAOH_Lead.setPreviousLeadScore((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.setUserIdForAllianceManager((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.setLeadCountry((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.updateInvalidEmailAndHardBouncebackDate((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
        DAOH_Lead.setValidateWebsite((List<Lead>)Records, (Map<Id, Lead>)existingRecords);
    }
    
    /**
     * CRM-MC-ESPSFDCQI-390
     * @params Map<Id, SObject> existingRecords
     * @return void
     */
    private void updateInvalidEmailAddress(Map<Id, SObject> existingRecords) {
        for(Lead leadRecord : (List<Lead>)Records) {
            if(existingRecords == null || leadRecord.Email != ((Lead)existingRecords.get(leadRecord.Id)).Email) {
                if(String.isBlank(leadRecord.Email)) {
                    leadRecord.Invalid_Email_Address__c = true; 
                    leadRecord.Consented_to_Marketing_Emails__c = ''; 
                }
            }
        }
    }
}