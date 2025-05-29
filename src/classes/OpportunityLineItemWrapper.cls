public class OpportunityLineItemWrapper {

        @AuraEnabled
        public OpportunityLineItem oliRecord;
        @AuraEnabled
        public String operationType;
        @AuraEnabled
        public List<OpportunityLineItemScheduleWrapper> revSchWrapperList;
    @AuraEnabled
    public List<String> therapyAreaOptions{get; set;}
        
        /**
         * constructor
         * @params  OpportunityLineItem oliRecord
         */
        public OpportunityLineItemWrapper(OpportunityLineItem oliRecord) {
            this.oliRecord = oliRecord;
            this.operationType = 'view';
            this.therapyAreaOptions = new List<String>();
            List<OpportunityLineItemSchedule> olisList = oliRecord.OpportunityLineItemSchedules;
            revSchWrapperList = new List<OpportunityLineItemScheduleWrapper>();
            for(OpportunityLineItemSchedule olis : olisList) {
                revSchWrapperList.add(new OpportunityLineItemScheduleWrapper(olis, CON_CRM.EDIT_LABEL));
            }
        }
        
        /**
         * constructor
         * @params  OpportunityLineItem oliRecord
         * @params  String operationType
         */
        public OpportunityLineItemWrapper(OpportunityLineItem oliRecord, String operationType) {
            this(oliRecord);
            this.operationType = operationType;
            this.therapyAreaOptions = new List<String>();
        }
}