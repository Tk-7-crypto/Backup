public class OpportunityLineItemScheduleWrapper {

    @AuraEnabled
    public OpportunityLineItemSchedule schRecord;
    @AuraEnabled
    public String operationType;
        
    /**
     * constructor
     * @params  OpportunityLineItemSchedule schRecord
     * @params  String operationType
     */
    public OpportunityLineItemScheduleWrapper(OpportunityLineItemSchedule schRecord, String operationType) {
        this.operationType = operationType;
        this.schRecord = schRecord;
    }
}