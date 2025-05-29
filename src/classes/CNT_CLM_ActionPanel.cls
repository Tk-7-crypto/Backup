/*
* This is a controller class for Action Panel through LWC 
*/ 
public class CNT_CLM_ActionPanel {
    
    /**
    * This function returns agreement on the basis of agreementId
    * @param Id agreementId 
    * @return Apttus__APTS_Agreement__c 
    */
    @AuraEnabled(cacheable = true)
    public static Apttus__APTS_Agreement__c getAgreementDetails(Id agreementId) {
        SObjectAccessDecision decision;
        Set<String> fields = new Set<String>{'Generate_AP_Custom__c', 'Cancel_Request_AP_Custom__c', 'Apttus__ImportSupportingDocument__c', 
            'Apttus__FF_View_Final_Contract__c', 'Regenerate_AP_Custom__c', 'Preview_AP_Custom__c', 'Apttus__FF_View_Draft_Contract__c', 'SendForReview_AP_Custom__c', 
            'Activate_AP_Custom__c', 'Amend_Custom__c', 'Apttus__FF_Terminate__c', 'UploadSignedDocument_AP_Custom__c', 'ImportOfflineDocument_AP_Custom__c', 
            'Expire_AP_Custom__c', 'Renew_AP_Custom__c', 'Apttus__FF_Agreement_Number__c', 'Apttus__Status__c', 'Apttus__Status_Category__c', 'Record_Type_Developer_Name__c', 
            'Apttus__Agreement_Category__c', 'Check_eSignature_Status_AP__c', 'Correct_E_Signature_Document_AP__c', 'Send_For_eSignature_AP__c', 'Recall_E_Signature_Request_AP__c', 
            'Send_e_Signature_Reminder_AP__c', 'Generate_Supporting_Document_AP__c', 'SendForWetSignatures_AP_Custom__c',
            'Apttus__Subtype__c', 'O365_Internal_Review_AP__c', 'Apttus__VersionAware__c'};
        try {
            decision = Security.stripInaccessible(AccessType.READABLE, new SLT_Agreement().getAgreementFieldsById(new Set<Id>{agreementId}, fields));
        }
        catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return (Apttus__APTS_Agreement__c)decision.getRecords()[0];
    }        

    /**
    * This method is used to fetch agreement fields for validation purposes
    * @param String recordId
    * @param String action
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> getAgreementFieldsForValidation(String recordId, String action) {
        String result;
        Set<String> fields = UTL_CLM.getSObjectTypeFields(Apttus__APTS_Agreement__c.SObjectType, true);
        fields.add('Record_Type_Developer_Name__c');
        fields.add('Apttus_QPComply__RelatedProposalId__r.Owner.Name');
        fields.add('Apttus_QPComply__RelatedProposalId__r.Owner.Email');
        fields.add('Legal_Entity_1__r.Q_Squared_Legal_Entity__c');
        fields.add('Original_Requested_Agreement_Type__c');
        Apttus__APTS_Agreement__c agr = SRV_CLM_Agreement.getAgreementDetailById(recordId, fields);
        result = (action == CON_CLM.ACTION_GENERATE) ? (UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agr, agr.Record_Type_Developer_Name__c, agr.Apttus__Subtype__c, CON_CLM.IN_AUTHORING, null, false)) 
            : (UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agr, agr.Record_Type_Developer_Name__c, agr.Apttus__Subtype__c, CON_CLM.IN_EFFECT, CON_CLM.ACTIVATED, false));
        List<String> lstFields = result.split('-', -2); 
        return lstFields;
    }
    
    /**
    * This method is used to get all section data
    * @return Map<String, List<String>>
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getSectionData() {
        Map<String, List<String>> sectionNameToFieldsMap = new Map<String, List<String>>();
        Set<String> secName = new Set<String>{'Information_Tab', 'IQVIA_Tab', 'Team_Tab', 'Term_And_Renewal_Tab', 'Unsigned_And_Plan_Tab'};
        for(String name : secName) {
            sectionNameToFieldsMap.put(name + '__c', UTL_CLM.getFieldSetValues(name));
        }    
        return sectionNameToFieldsMap;
    }
}