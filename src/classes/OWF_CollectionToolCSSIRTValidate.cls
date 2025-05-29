public with sharing class OWF_CollectionToolCSSIRTValidate implements INT_OWF_CollectionToolValidation {
    private List<CollectionTool__c> collectionRecords{get; set;}
    private OWF_GenericCollectionToolHelper.CollectionToolConfig config{get; set;}

    public Set<String> validate(OWF_GenericCollectionToolHelper.CollectionToolConfig config, List<CollectionTool__c> collectionRecords) {
        Set<String> errors = new Set<String>(); 
        this.collectionRecords = collectionRecords;
        this.config = config;
        for(CollectionTool__c record : this.collectionRecords) {
            if(record.User_Guide_Translation_Required__c == 'Yes' && record.No_of_Non_English_Language__c == null) {
                errors.add('Please Fill "No of Non English Language" in IRT');
            }
        }
        return errors;
    }
}