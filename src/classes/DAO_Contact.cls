/**
* This is Contact Domain class.
* version : 1.0
*/
public class DAO_Contact extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<SObject>
    */
    public DAO_Contact(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Contact(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Contact trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        updateInvalidEmailAddress(null);
        setMulesoftIntegrationFields((List<Contact>)Records,null, null);
        DAOH_Contact.setDispositionDate((List<Contact>)Records, null);
        DAOH_Contact.setFieldNullValues((List<Contact>)Records);
        DAOH_Contact.checkUserContactRelationCSM((List<Contact>)Records);
        DAOH_Contact.checkPhoneMobileValidation((List<Contact>)Records);
        DAOH_Contact.iqviaInternalContactValidations((List<Contact>)Records,null);
        DAOH_Contact.setContactFields((List<Contact>)Records,null);
        DAOH_Contact.CopyAccountAddressToMailingAddress((List<Contact>)Records,null);
        DAOH_Contact.setPseResource((List<Contact>)Records);
        DAOH_Contact.removeCSHUserAccess((List<Contact>)Records,null);
        DAOH_OWF_Contact.validateBaselineFTE((List<Contact>)Records,null);
    }
    
    /**
    * This method is used for after insert of the case trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_Contact.saveAuditLogAfterInsertContact((List<Contact>)Records);
        DAOH_Contact.addPermissionSetAfterInsertCSM((List<Contact>)Records);
        DAOH_Contact.createChatterUsers((List<Contact>)Records,null);
    }
    
    /**
         * This method is used to populate Defaults fields of the Contact trigger.
         * @return void
         */
    public override void onApplyDefaults() {
        for(Contact contactRecord : (List<Contact>)Records) {
            if(String.isBlank(contactRecord.Source__c)) {
                contactRecord.Source__c = 'Salesforce';
            }
        }
    }
    
    /**
    * This method is used for before update of the Contact trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        /*Profile profile = null;
        if(UserInfo.getProfileId() != null){
            profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        }
        if(!System.isBatch() && profile != null && profile.Name != null && profile.Name != 'IQVIA Salesforce Platform Support' && !profile.Name.containsIgnoreCase(CON_CSM.S_P_SYS_ADMIN)){
            DAOH_Contact.deactivateCommunityUser((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        }*/
        updateInvalidEmailAddress(existingRecords);
        setMulesoftIntegrationFields((List<Contact>)Records, new Map<Id,Contact>((List<Contact>)Records), (Map<Id,Contact>)existingRecords);
        DAOH_Contact.setDispositionDate((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        DAOH_Contact.setFieldNullValues((List<Contact>)Records);
        DAOH_Contact.resetLegacyAccountId(new Map<Id, Contact>((List<Contact>)Records), (Map<Id, Contact>)existingRecords);
        DAOH_Contact.checkUserContactRelationCSM((List<Contact>)Records);
        DAOH_Contact.setPreviousLeadScore((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        DAOH_Contact.validateInternalContactsMerge((List<Contact>)Records);
        DAOH_Contact.checkPhoneMobileValidation((List<Contact>)Records);
        DAOH_Contact.preventUpdateContactAccWithActiveUser((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        DAOH_Contact.iqviaInternalContactValidations((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        DAOH_Contact.updateorValidatePortalUserFieldsContact((List<Contact>)Records, (Map<Id, Contact>)existingRecords);
        DAOH_Contact.setContactFields((List<Contact>)Records,(Map<Id, Contact>)existingRecords);
        DAOH_Contact.updateInvalidEmailAndHardBouncebackDate((List<Contact>)Records,(Map<Id, Contact>)existingRecords);
        DAOH_Contact.CopyAccountAddressToMailingAddress((List<Contact>)Records,(Map<Id, Contact>)existingRecords);
        DAOH_Contact.setPseResource((List<Contact>)Records);
        DAOH_Contact.removeCSHUserAccess((List<Contact>)Records,(Map<Id, Contact>)existingRecords);
        DAOH_OWF_Contact.validateBaselineFTE((List<Contact>)Records,(Map<Id,Contact>)existingRecords);
    }
 
    /**
* This method is used for after update of the Contact trigger.
* @params  Map<Id, SObject> existingRecords
* @return void
*/
    private boolean isUserSystemAdmin(){
        string adminProfile='System Administrator';
        string serviceProfile='Service User';
        string salesProfile='Sales User';
        String pName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Label = 'Advanced Administrator' AND AssigneeId = :UserInfo.getUserId()];
        if(pName.equals(adminProfile) || (pName.equals(serviceProfile) && (permissionSetAssignments.size()>0)) || pName.equals(salesProfile)){
            return true;
        }else{
            return false;
        }    
    }
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.s_contact);
        if(fields != null){ 
            DAOH_Contact.saveAuditLogAfterUpdateContactFields((List<Contact>)Records,(Map<Id,Contact>)existingRecords,fields); 
        }
        DAOH_Contact.PermissionSetAfterUpdateCSM((List<Contact>)Records,(Map<Id,Contact>)existingRecords);
        DAOH_Contact.updateUserForContacts((List<Contact>)records, (Map<Id,Contact>)existingRecords);
        DAOH_OWF_Contact.closeRelatedAssignmentsOnUpdate((List<Contact>)Records,(Map<Id,Contact>)existingRecords);
        DAOH_Contact.createChatterUsers((List<Contact>)Records,(Map<Id,Contact>)existingRecords);
        DAOH_Contact.disablePortalAccess((List<Contact>)Records,(Map<Id,Contact>)existingRecords);
    }
    
    /**
    * CRM-MC-ESPSFDCQI-390
    * @params Map<Id, SObject> existingRecords
    * @return void
    */
    private void updateInvalidEmailAddress(Map<Id, SObject> existingRecords) {
        for(Contact contactRecord : (List<Contact>)Records) {
            if(existingRecords == null || contactRecord.Email != ((Contact)existingRecords.get(contactRecord.Id)).Email) {
                if(String.isBlank(contactRecord.Email)) {
                    contactRecord.Invalid_Email_Address__c = true; 
                    contactRecord.Consented_to_Marketing_Emails__c = ''; 
                }
            }
        }
    }
    
    /**
    * Override method Before Delete Call
    */
    public override void onBeforeDelete() {
        DAOH_Contact.validateDeletionOnRecordType((List<Contact>)Records);
    } 
    
    /**
    * Override method After Delete Call
    */
    public override void onAfterDelete() {
        createOutboundMessageDeletionQueue((List<Contact>)Records);
    } 
    
    /**
    * This method is used to update Outbound Message Deletion Queue
    * @params  List<Contact> deleteList
    * @return  void
    */
    public static void createOutboundMessageDeletionQueue(List<Contact> deleteList) {
    	fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
                }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contact cnt : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(cnt.LI_Contact_Id__c != null) {
                outBound.LI_Id__c = cnt.LI_Contact_Id__c;
            }
            if(cnt.LQ_Contact_Id__c != null) {
                outBound.LQ_Id__c = cnt.LQ_Contact_Id__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTACT_OBJECT;
            outBound.RecordID__c = cnt.Id;
            outBound.MasterRecordId__c = cnt.MasterRecordId;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    /**
    * This method is used to set Mulesoft Integration Fields on Contact.
    * @param newList List<Contact>
    * @params  newMap Map<Id, Contact>
    * @params  oldMap Map<Id, Contact>
    * @return  void
    */
    public static void setMulesoftIntegrationFields(List<Contact> newList, Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        Boolean setFlag = false;
        String fieldAPI ='';
        for(Contact con : newList) {
            setFlag = false;
            if(Trigger.isUpdate) {
                con.Send_Mulesoft_Outbound_Msg__c = false;
                for( Schema.FieldSetMember sf : Schema.SObjectType.Contact.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                    fieldAPI = sf.getFieldPath();
                    if(oldMap.get(con.Id).get(fieldAPI) != newMap.get(con.Id).get(fieldAPI)) {
                        setFlag = true ;
                        break;
                    }
                }
            }
            if(Trigger.isInsert || setFlag) {
                con.Send_Mulesoft_Outbound_Msg__c = true;
                con.LI_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                con.LQ_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                con.LI_Mulesoft_Sync_Status__c = 'PENDING';
                con.LQ_Mulesoft_Sync_Status__c = 'PENDING';
                con.LI_Mulesoft_Sync_Timestamp__c = null;
                con.LQ_Mulesoft_Sync_Timestamp__c = null;
                con.LI_Mulesoft_Error_Message__c = null;
                con.LQ_Mulesoft_Error_Message__c = null;
            }
        }
   }
}
