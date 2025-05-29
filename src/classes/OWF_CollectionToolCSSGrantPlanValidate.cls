public with sharing class OWF_CollectionToolCSSGrantPlanValidate implements INT_OWF_CollectionToolValidation{
    private List<CollectionTool__c> collectionRecords{get; set;}
    private OWF_GenericCollectionToolHelper.CollectionToolConfig config{get; set;}

    public Set<String> validate(OWF_GenericCollectionToolHelper.CollectionToolConfig config, List<CollectionTool__c> collectionRecords) {
        Set<String> errors = new Set<String>(); 
        this.collectionRecords = collectionRecords;
        this.config = config;
        for(CollectionTool__c record : this.collectionRecords) {
            if(record.Grant_Plan_Module__c == 'Grant Plan (Sponsor)' && (record.Tier__c == null || record.Duration__c == null || record.Number_of_Studies_Licences_py__c == null)) {
                errors.add('Please Fill "Tier,Duration and Number of Studies/Licences py" in Grant Plan');
            }
            else if(record.Grant_Plan_Module__c == 'Standard of Care' && (record.Tier__c == null || record.Duration__c == null )) {
                errors.add('Please Fill "Tier and Duration" in Grant Plan');
            }
            else if(record.Grant_Plan_Module__c == 'GrantPlan for Investigator' && (record.Tier__c == null || record.Duration__c == null || record.Number_of_Studies_Licences_py__c == null)) {
                errors.add('Please Fill "Tier,Duration and Number of Studies/Licences py" in Grant Plan');
            }
            else if(record.Grant_Plan_Module__c == 'Budget Build' && (record.Number_of_Countries__c == null || record.Number_of_Studies_Licences_py__c == null)) {
                errors.add('Please Fill "Number of countries and Number of Studies/Licences py" in Grant Plan');
            }
        }
        return errors;
    }
}