public class PriceBookEntryWrapper {
    
    @AuraEnabled
    public Product2 productRecord;
    @AuraEnabled
    public PriceBookEntry pbeRecord;
    @AuraEnabled
    public List<String> productIds;
    @AuraEnabled
    public Favorite_Product__c favRecord {get; set;}
    @AuraEnabled
    public Integer totalRecords {get; set;}
    @AuraEnabled
    public Integer recordLimit {get; set;}
    
    /**
     * constructor
     * @params  Product2 productRecord
     * @params  PriceBookEntry pbeRecord
     */
    public PriceBookEntryWrapper(Product2 productRecord, PriceBookEntry pbeRecord) {
        this.productRecord = productRecord;
        this.pbeRecord = pbeRecord;
        this.productIds = new List<String>();
    }
    
    /**
     * constructor
     * @params  Product2 productRecord
     */
    public PriceBookEntryWrapper(Product2 productRecord) {
        this.productRecord = productRecord;
        this.pbeRecord = new PriceBookEntry();
        this.productIds = new List<String>();
    }
    
    public PriceBookEntryWrapper(Product2 productRecord,List<String> ids) {
        this.productRecord = productRecord;
        this.pbeRecord = new PriceBookEntry();
        this.productIds = ids;
    }
    
    public PriceBookEntryWrapper(Product2 productRecord, PriceBookEntry pbeRecord, Favorite_Product__c favRecord) {
        this.productRecord = productRecord;
        this.pbeRecord = pbeRecord;
        this.favRecord = favRecord;
    }
    
    public PriceBookEntryWrapper(Product2 productRecord, PriceBookEntry pbeRecord, Integer totalRecords, Integer recordLimit) {
        this.productRecord = productRecord;
        this.pbeRecord = pbeRecord;
        this.totalRecords = totalRecords;
        this.recordLimit = recordLimit;
    }
    
}