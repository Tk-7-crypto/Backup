public class OWF_CollectionToolBioSciencesValidate implements INT_OWF_CollectionToolValidation {
    private List<CollectionTool__c> collectionRecords{get; set;}
    private OWF_GenericCollectionToolHelper.CollectionToolConfig config{get; set;}
    private Map<Id, String> productCodeMap{get; set;}
	public Set<String> validate(OWF_GenericCollectionToolHelper.CollectionToolConfig config, List<CollectionTool__c> collectionRecords) {
        Set<String> errors = new Set<String>(); 
        this.collectionRecords = collectionRecords;
        this.config = config;
        initSupportiveData();       
        for(CollectionTool__c record : this.collectionRecords) {
            if(config.validationRule?.validationRules != null) {             
                for(OWF_GenericCollectionToolHelper.ValidationRule rule : config.validationRule.validationRules) {
                    if(rule.ruleName == 'serviceLineValidation') {
                        Boolean validate = serviceLineValidation(record, rule.ruleAttributes);  
                        if(validate) {
                            errors.add(rule.errorMessage);
                            break;
                        }
                    } 
                }
            }
        }
        return errors;
    }
    
    private Boolean serviceLineValidation(CollectionTool__c record, List<String> attributes){
        Map<String, Set<String>> siteServiceLineMap = new Map<String, Set<String>>();
        for(String att : attributes) {
            String[] attrs = att.split('#');
            siteServiceLineMap.put(attrs[0], new Set<String>(attrs[1].split(',')));
        }
        String serviceSapCode =  productCodeMap.get(record.ServiceLine__c);
        return siteServiceLineMap.containsKey(record.Site_Global__c) && !siteServiceLineMap.get(record.Site_Global__c).contains(serviceSapCode);
    }
    
    private void initSupportiveData(){
        Set<Id> productIds = new Set<Id>();
        for(CollectionTool__c record : this.collectionRecords){
            productIds.add(record.ServiceLine__c);
        }
        productCodeMap = new Map<Id, String>();
        for(Product2 product : [Select Id, SAP_Code__c FROM Product2 WHERE Id = :productIds]){
            productCodeMap.put(product.Id, product.SAP_Code__c);
        }
    }
}