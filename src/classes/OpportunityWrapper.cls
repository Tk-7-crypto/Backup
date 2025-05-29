/*
 * Version       : 1.0
 * Description   : Opportunity Wrapper Class  
 */
public Class OpportunityWrapper {
    
    @AuraEnabled
    public Opportunity opportunityRecord;
    @AuraEnabled
    public Quote__c quoteRecord;
    @AuraEnabled
    public List<PriceBookEntryWrapper> priceBookEntryWrapperList;
    @AuraEnabled
    public List<OpportunitySplitWrapper> oppSplitWrapperList;
    @AuraEnabled
    public List<OpportunityTeamMember> oppTeamMemberList;
    @AuraEnabled
    public List<OpportunityLineItemWrapper> oliWrapperList;
    @AuraEnabled
    public List<OpportunityLineItemScheduleWrapper> olischWrapperList;
    @AuraEnabled
    public EsatblisOpportunityLineItemScheduleWrapper establishWrapper;
    @AuraEnabled
    public List<ObjectFieldsWrapper> objectFieldsWrapperList;
    @AuraEnabled
    public Default_Product_Search__c defaultProductSearch;
    @AuraEnabled
    public Decimal decimalPlace;
    @AuraEnabled
    public Decimal decimalPlaceStep;
    
    
    
    /**
     * constructor 
     */
    public OpportunityWrapper() {
        this.opportunityRecord = new Opportunity();
        this.oppSplitWrapperList = new List<OpportunitySplitWrapper>();
        this.oppTeamMemberList = new List<OpportunityTeamMember>();
        this.oliWrapperList = new List<OpportunityLineItemWrapper>();
    }
    
    /**
     * constructor
     * @params  Opportunity opportunityRecord
     * @params  List<ObjectFieldsWrapper> objectFieldsWrapperList
     * @params  Default_Product_Search__c defaultProductSearch
     */
    public OpportunityWrapper(Opportunity opportunityRecord, List<ObjectFieldsWrapper> objectFieldsWrapperList, Default_Product_Search__c defaultProductSearch) {
        this.opportunityRecord = opportunityRecord;
        this.objectFieldsWrapperList = objectFieldsWrapperList;
        this.defaultProductSearch = defaultProductSearch;
    }
    
    /**
     * constructor
     * @params  Quote__c quoteRecord
     * @params  List<ObjectFieldsWrapper> objectFieldsWrapperList
     * @params  Default_Product_Search__c defaultProductSearch
     */
    public OpportunityWrapper(Quote__c quoteRecord, List<ObjectFieldsWrapper> objectFieldsWrapperList, Default_Product_Search__c defaultProductSearch) {
        this.quoteRecord = quoteRecord;
        this.objectFieldsWrapperList = objectFieldsWrapperList;
        this.defaultProductSearch = defaultProductSearch;
    }
    
    /**
     * constructor
     * @params  Opportunity opportunityRecord
     * @params  List<OpportunitySplitWrapper> oppSplitWrapperList
     * @params  List<OpportunityTeamMember> oppTeamMemberList
     */
    public OpportunityWrapper(Opportunity opportunityRecord, List<OpportunitySplitWrapper> oppSplitWrapperList, List<OpportunityTeamMember> oppTeamMemberList) {
        this.opportunityRecord = opportunityRecord;
        this.oppSplitWrapperList = oppSplitWrapperList;
        this.oppTeamMemberList = oppTeamMemberList;
    }
    
    /**
     * constructor
     * @params  Opportunity opportunityRecord
     * @params  List<OpportunitySplitWrapper> oppSplitWrapperList
     * @params  List<OpportunityTeamMember> oppTeamMemberList
     * @params  Decimal decimalPlace
     * @params  Decimal decimalPlaceStep
     */
    public OpportunityWrapper(Opportunity opportunityRecord, List<OpportunitySplitWrapper> oppSplitWrapperList, List<OpportunityTeamMember> oppTeamMemberList, Decimal decimalPlace, Decimal decimalPlaceStep) {
        this.opportunityRecord = opportunityRecord;
        this.oppSplitWrapperList = oppSplitWrapperList;
        this.oppTeamMemberList = oppTeamMemberList;
        this.decimalPlace = decimalPlace;
        this.decimalPlaceStep = decimalPlaceStep;
    }
    
    /**
     * constructor
     * @params  List<OpportunityLineItemWrapper> oliWrapperList
     */
    public OpportunityWrapper(List<OpportunityLineItemWrapper> oliWrapperList) {
        this.oliWrapperList = oliWrapperList;
    }
    
    /**
     * constructor
     * @params  List<OpportunityLineItemWrapper> oliWrapperList
     * @params  Decimal decimalPlace
     * @params  Decimal decimalPlaceStep
     */
    public OpportunityWrapper(List<OpportunityLineItemWrapper> oliWrapperList, Decimal decimalPlace, Decimal decimalPlaceStep) {
        this.oliWrapperList = oliWrapperList;
        this.decimalPlace = decimalPlace;
        this.decimalPlaceStep = decimalPlaceStep;
    }
    
    /**
     * constructor
     * @params  List<OpportunityLineItemScheduleWrapper> oliWrapperList
     */
    public OpportunityWrapper(List<OpportunityLineItemScheduleWrapper> olischWrapperList) {
        this.olischWrapperList = olischWrapperList;
    }
    
    // Inner Opportunity Split Wrapper
    public Class OpportunitySplitWrapper {
        @AuraEnabled
        public OpportunitySplit splitRecord;
        @AuraEnabled
        public String operationType;

        /**
         * constructor
         */
        public OpportunitySplitWrapper() {
            this.splitRecord = new OpportunitySplit();
            this.operationType = 'view';
        }
        
        /**
         * constructor
         * @params  OpportunitySplit splitRecord
         * @params  String operationType
         */
        public OpportunitySplitWrapper(OpportunitySplit splitRecord, String operationType) {
            this.splitRecord = splitRecord;
            this.operationType = operationType;
        }
    }
    
    // Inner EsatblisOpportunityLineItemScheduleWrapper
    public class EsatblisOpportunityLineItemScheduleWrapper {
        
        @AuraEnabled
        public Id oliId;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Decimal revenue;
        @AuraEnabled
        public String scheduleType;
        @AuraEnabled
        public String installmentPeriod;
        @AuraEnabled
        public Integer noOfInstallment;
        @AuraEnabled
        public String type;
        
        /**
         * constructor
         * @params  OpportunityLineItemSchedule schRecord
         * @params  String operationType
         */
        public EsatblisOpportunityLineItemScheduleWrapper(Id oliId, Date startDate, Decimal revenue, String scheduleType, String installmentPeriod, Integer noOfInstallment, String type) {
            this.oliId = oliId;
            this.startDate = startDate;
            this.revenue = revenue;
            this.scheduleType = scheduleType;
            this.installmentPeriod = installmentPeriod;
            this.noOfInstallment = noOfInstallment;
            this.type = type;
        }
    }
}