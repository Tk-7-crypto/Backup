public with sharing class OWF_CollectionToolCSSeTMFValidate implements INT_OWF_CollectionToolValidation{
    private List<CollectionTool__c> collectionRecords{get; set;}
    private OWF_GenericCollectionToolHelper.CollectionToolConfig config{get; set;}

    public Set<String> validate(OWF_GenericCollectionToolHelper.CollectionToolConfig config, List<CollectionTool__c> collectionRecords) {
        Set<String> errors = new Set<String>(); 
        this.collectionRecords = collectionRecords;
        this.config = config;
        for(CollectionTool__c record : this.collectionRecords) {
            if((record.eTMF_Module__c == 'eTMF SaaS Subscription' || record.eTMF_Module__c == 'eTMF Essentials' )&& (record.Number_of_Studies__c == null || record.Number_of_Sites__c == null )) {
                errors.add('Please Fill "Number of sites and Number of Studies" in eTMF');
            }
            else if(record.eTMF_Module__c == 'eArchive' && record.Number_of_Studies__c == null ) {
                errors.add('Please Fill "Number of Studies" in eTMF');
            }
            else if(record.eTMF_Module__c == 'Migration' && (record.Number_of_Documents__c == null || record.Source_of_TMFs__c == null) ) {
                errors.add('Please Fill "Source of TMFs and Number of Documents" in eTMF');
            }
            else if(record.eTMF_Module__c == 'File Review' && record.Number_of_Documents__c == null ) {
                errors.add('Please Fill "Number of Documents" in eTMF');
            }
        }
        return errors;
    }
}