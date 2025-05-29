/**
 * This is Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c trigger handler class.
 * version : 1.0 
 */
public class DAO_APTS_DocuApi_DocuSignEnvelopeRS extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>
     */
    public DAO_APTS_DocuApi_DocuSignEnvelopeRS(List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> sObjectList) {
        super(sObjectList);
        if(UTL_ExecutionControl.disableTriggerCRUDAGR) {
            Configuration.disableTriggerCRUDSecurity();       
        }
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_APTS_DocuApi_DocuSignEnvelopeRS(sObjectList);
        }
    }
    
    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            Outbound_Message_Deletion_queue__c.SobjectType
        }
    );

    /**
     * This method is used for after insert of the Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus : (List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>)Records) {
            lstDocuSignEnvelopeRecipientStatus.add(docuSignEnvelopeRecipientStatus);
        }
        if(lstDocuSignEnvelopeRecipientStatus.size() > 0){
            DAOH_APTS_DocuApi_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        }
    }
    
    /**
     * This method is used for after update of the Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c trigger.
     * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        Map<Id, Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> OldMap = (Map<Id, Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>)existingRecords;
        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus : (List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>)Records) {
            if(docuSignEnvelopeRecipientStatus.Apttus_DocuApi__Status__c != 
                OldMap.get(docuSignEnvelopeRecipientStatus.Id).Apttus_DocuApi__Status__c) {
                lstDocuSignEnvelopeRecipientStatus.add(docuSignEnvelopeRecipientStatus);
            }
        }
        if(lstDocuSignEnvelopeRecipientStatus.size() > 0){
            DAOH_APTS_DocuApi_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        }
    }
}