public class DAO_IQ_Quote extends fflib_SObjectDomain {  
    /**
     * Constructor of this class
     * @params sObjectList List<Quote__c>
     */
    public DAO_IQ_Quote(List<Quote__c> sObjectList) {
        super(sObjectList);
        if (UTL_ExecutionControl.disableTriggerCRUDIQQuote) {
            Configuration.disableTriggerCRUDSecurity();
        }
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_IQ_Quote(sObjectList);
        }
    }

    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork (
        new Schema.SObjectType[] { Outbound_Message_Deletion_queue__c.SobjectType }
    );
    
    public override void onApplyDefaults() {}

    /**
     * This method is used for before insert of the IQVIA Quote trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_IQ_Quote.setAccountCountry((List<Quote__c>)Records, null);
        DAOH_IQ_Quote.setLastSharingCalculationTimestamp((List<Quote__c>)Records, null); 
        DAOH_IQ_Quote.updateIterationOnQuote((List<Quote__c>)Records, null);
        DAOH_IQ_Quote.setDefaults((List<Quote__c>)Records); 
        DAOH_IQ_Quote.validateDiscount((List<Quote__c>)Records, null);
        DAOH_IQ_Quote.setConversionRate((List<Quote__c>)Records, null);
        DAOH_IQ_Quote.setQuoteName((List<Quote__c>)Records);
    }
    
    /**
     * This method is used for after insert of the IQVIA Quote trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_IQ_Quote.setDummyCreatorAccess((List<Quote__c>)records);
        //This should be at the last since it will implement the sharing
        DAOH_IQ_Quote.setSharing((List<Quote__c>)Records, null);
    }
    
    /**
     * This method is used for before update of the IQVIA Quote trigger.
     * @params  existingRecords Map<Id, SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_IQ_Quote.setLastManualSharingFieldUpdate((List<Quote__c>)Records,null);
        DAOH_IQ_Quote.setAccountCountry((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setLastSharingCalculationTimestamp((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.checkAvailableCurrency((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.updateIterationOnQuote((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setDefaults((List<Quote__c>)Records);
        DAOH_IQ_Quote.validateDiscount((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setAcceptedDate((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setTotolICFDocuments((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setConversionRate((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setApprovalStage((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.updateNextApprovalStep((List<Quote__c>)Records,(Map<Id, Quote__c>)existingRecords);
        List<Quote__c> listOfRDSQuotes = new List<Quote__c>();
        for (Quote__c quote :(List<Quote__c>)Records) {
            if (quote.GBU__c == CON_CPQ.GBU_RDS_SF || quote.GBU__c == CON_CPQ.GBU_RDS_NON_SF) {
                listOfRDSQuotes.add(quote);
            }
        }
        if (listOfRDSQuotes.size() > 0) {
            DAOH_IQ_Quote.validateRDSQuoteStages(listOfRDSQuotes,(Map<Id, Quote__c>)existingRecords);
        }
    }
    
    /**
     * This method is used for after update of the IQVIA Quote trigger. 
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_IQ_Quote.setCurrency((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.checkForAutoApproval((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        DAOH_IQ_Quote.setAmountOnQuote((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
        SRV_CRM_Field_History fieldHistoryService = SRV_CRM_Field_History.getInstance('IQVIA_Quote');
        fieldHistoryService.saveFieldHistories((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);

        //This should be at the last since it will implement the sharing
        DAOH_IQ_Quote.setSharing((List<Quote__c>)Records, (Map<Id, Quote__c>)existingRecords);
    }
	
    /**
     * This method is used for before Delete of the IQVIA Quote trigger.
     * @return void
     */
    public override void onBeforeDelete() {}
	
    /**
     * This method is used for after Delete of the IQVIA Quote trigger.
     * @return void
     */
    public override void onAfterDelete() {}
}
