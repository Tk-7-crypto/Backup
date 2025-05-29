/**
 * This is DocuSignEnvelopeRecipientStatus__c trigger handler class.
 * version : 1.0 
 */
public class DAO_IQ_DocuSignEnvelopeRS extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<DocuSignEnvelopeRecipientStatus__c>
     */
    public DAO_IQ_DocuSignEnvelopeRS(List<IQ_DocuSignEnvelopeRecipientStatus__c> sObjectList) {
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
            return new DAO_IQ_DocuSignEnvelopeRS(sObjectList);
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
     * This method is used for after insert of the IQ_DocuSignEnvelopeRecipientStatus__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        List<IQ_DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        for(IQ_DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus : (List<IQ_DocuSignEnvelopeRecipientStatus__c>)Records) {
            lstDocuSignEnvelopeRecipientStatus.add(docuSignEnvelopeRecipientStatus);
        }
        if(lstDocuSignEnvelopeRecipientStatus.size() > 0){
            DAOH_CLM_IQ_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        }
    }
    
    /**
     * This method is used for after update of the IQ_DocuSignEnvelopeRecipientStatus__c trigger.
     * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<IQ_DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        Map<Id, IQ_DocuSignEnvelopeRecipientStatus__c> oldMap = (Map<Id, IQ_DocuSignEnvelopeRecipientStatus__c>)existingRecords;
        for(IQ_DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus : (List<IQ_DocuSignEnvelopeRecipientStatus__c>)Records) {
            if(docuSignEnvelopeRecipientStatus.Status__c != 
                oldMap.get(docuSignEnvelopeRecipientStatus.Id).Status__c) {
                lstDocuSignEnvelopeRecipientStatus.add(docuSignEnvelopeRecipientStatus);
            }
        }
        if(lstDocuSignEnvelopeRecipientStatus.size() > 0){
            DAOH_CLM_IQ_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        }
    }
}