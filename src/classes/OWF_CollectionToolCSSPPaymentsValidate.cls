public with sharing class OWF_CollectionToolCSSPPaymentsValidate implements INT_OWF_CollectionToolValidation{
    private List<CollectionTool__c> collectionRecords{get; set;}
    private OWF_GenericCollectionToolHelper.CollectionToolConfig config{get; set;}

    public Set<String> validate(OWF_GenericCollectionToolHelper.CollectionToolConfig config, List<CollectionTool__c> collectionRecords) {
        Set<String> errors = new Set<String>(); 
        this.collectionRecords = collectionRecords;
        this.config = config;
        for(CollectionTool__c record : this.collectionRecords) {
            if(record.Participant_Payments__c == 'Enrolled' && (record.Number_of_Visits_per_Enrolled_Patients__c == null || record.Patient_Drop_Out_Rate__c == null || record.No_of_Phone_eDiary_Engagements__c == null)) {
                errors.add('Please Fill "Number of visits per enrolled patients,Patient Drop out rate %,No. of phone/eDiary engagements" in Participant Payments');
            }
            else if(record.Participant_Payments__c == 'Screened' && record.Screened_Pts_Receive_Payment__c == null  ) {
                errors.add('Please Fill "Screened pts receive payment" in Participant Payments');
            }
            else if(record.Participant_Payments__c == 'Caregiver' && record.Total_of_Caregiver_s_per_Patient__c == null ) {
                errors.add('Please Fill "Total # of caregiver(s) per patient" in Participant Payments');
            }
        }
        return errors;
    }
}