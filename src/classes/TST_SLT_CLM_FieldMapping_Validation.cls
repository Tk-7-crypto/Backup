@isTest
public class TST_SLT_CLM_FieldMapping_Validation {
    @isTest
    private static void testGetCLMFieldMappingValidationByConditionInEffect() {
        Set<String> fields = new Set<String>{'Field_API_Name__c', 'Status__c', 'Requested_Agreement_Type__c',
            'Show_Different_Message_On_VF__c'};
        String condition = 'Record_Type__c =: recordTypeDeveloperName AND Status_Category__c=:statusCategory';
        List<CLM_FieldMapping_Validation__mdt> clmFieldMappingValidation = null;
        Test.startTest();
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'RWSSOW', CON_CLM.IN_EFFECT);
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'OSA', CON_CLM.IN_EFFECT);
        Test.stopTest();
        
        System.assertEquals(true, clmFieldMappingValidation.size() > 0, 'Method should return list');    
    }
    @isTest
    private static void testGetCLMFieldMappingValidationByConditionInAuth() {
        Set<String> fields = new Set<String>{'Field_API_Name__c', 'Status__c', 'Requested_Agreement_Type__c',
            'Show_Different_Message_On_VF__c'};
        String condition = 'Record_Type__c =: recordTypeDeveloperName AND Status_Category__c=:statusCategory';
        List<CLM_FieldMapping_Validation__mdt> clmFieldMappingValidation = null;
        Test.startTest();
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'OSA', CON_CLM.IN_AUTHORING);
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'Preliminary_Agreement', CON_CLM.IN_AUTHORING);
        Test.stopTest();
        
        System.assertEquals(true, clmFieldMappingValidation.size() > 0, 'Method should return list');    
    }
    @isTest
    private static void testGetCLMFieldMappingValidationByConditionRequest() {
        Set<String> fields = new Set<String>{'Field_API_Name__c', 'Status__c', 'Requested_Agreement_Type__c',
            'Show_Different_Message_On_VF__c'};
        String condition = 'Record_Type__c =: recordTypeDeveloperName AND Status_Category__c=:statusCategory';
        List<CLM_FieldMapping_Validation__mdt> clmFieldMappingValidation = null;
        Test.startTest();
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'OSA', CON_CLM.IN_BUDGETING);
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'PSA', CON_CLM.IN_BUDGETING);
        Test.stopTest();
        
        System.assertEquals(true, clmFieldMappingValidation.size() > 0, 'Method should return list');    
    }
    @isTest
    private static void testGetCLMFieldMappingValidationByConditionInSign() {
        Set<String> fields = new Set<String>{'Field_API_Name__c', 'Status__c', 'Requested_Agreement_Type__c',
            'Show_Different_Message_On_VF__c'};
        String condition = 'Record_Type__c =: recordTypeDeveloperName AND Status_Category__c=:statusCategory';
        List<CLM_FieldMapping_Validation__mdt> clmFieldMappingValidation = null;
        Test.startTest();
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'PSA', CON_CLM.IN_SIGNATURES);
            clmFieldMappingValidation = new SLT_CLM_FieldMapping_Validation().
                getCLMFieldMappingValidationByCondition(fields, condition, 'MSA', CON_CLM.IN_SIGNATURES);
        Test.stopTest();
        
        System.assertEquals(true, clmFieldMappingValidation.size() > 0, 'Method should return list');    
    }
}