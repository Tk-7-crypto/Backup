public class MIBNFCompWrapper {
    @AuraEnabled
    public MIBNF_Component__c mibnfComp{get;set;}
    @AuraEnabled
    public Map<Id, OpportunityLineItem> oliMap{get;set;}
    @AuraEnabled
    public Map<Id, List<Billing_Schedule_Item__c>> billischMap{get;set;}
    @AuraEnabled
    public Boolean canUpdateOppPrice{get;set;}
    
    
    public MIBNFCompWrapper(){
        
    }
    
    /**
     * constructor
     * @params  List<Billing_Schedule_Item__c> billingScheduleList
     * @params  OpportunityLineItem oliData
     */
    public MIBNFCompWrapper(MIBNF_Component__c mibnfComp, Map<Id, OpportunityLineItem> oliMap,Map<Id, List<Billing_Schedule_Item__c>> billischMap, Boolean canUpdateOppPrice) {
        this.mibnfComp = mibnfComp;
        this.oliMap = oliMap;
        this.billischMap = billischMap;
        this.canUpdateOppPrice = canUpdateOppPrice;
    }
}