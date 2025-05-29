/**
* Selector class for CLM_FieldMapping_Validation__mdt MetaData
*/
public class SLT_CLM_FieldMapping_Validation extends fflib_SObjectSelector {

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_CLM_FieldMapping_Validation() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_CLM_FieldMapping_Validation(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return CLM_FieldMapping_Validation__mdt.sObjectType;
    }

    /**
    * This method gives the list of SObjectField of CLM_FieldMapping_Validation__mdt Metadata.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CLM_FieldMapping_Validation__mdt.Id, CLM_FieldMapping_Validation__mdt.Field_API_Name__c, CLM_FieldMapping_Validation__mdt.Status__c, CLM_FieldMapping_Validation__mdt.Requested_Agreement_Type__c, CLM_FieldMapping_Validation__mdt.Record_Type__c, CLM_FieldMapping_Validation__mdt.Status_Category__c
        };
    }
    
    /**
    * This method used to get list of CLM_FieldMapping_Validation__mdt base on condition
    * @param fields is the set of fields.
    * @param condition.
    * @param recordTypeDeveloperName
    * @param statusCategory
    * @return  list
    */
    public List<CLM_FieldMapping_Validation__mdt> getCLMFieldMappingValidationByCondition(Set<String> fields, String condition,
        String recordTypeDeveloperName, String statusCategory) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        if(Test.isRunningTest()){
            List<CLM_FieldMapping_Validation__mdt> listOfTestMetaData = new List<CLM_FieldMapping_Validation__mdt>();
            if(statusCategory == CON_CLM.IN_AUTHORING){
                if(recordTypeDeveloperName == CON_CLM.PA_RECORD_TYPE_NAME) {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Record_Type__c = CON_CLM.PA_RECORD_TYPE_NAME,Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Status_Category__c = CON_CLM.IN_AUTHORING));
                }
                if(recordTypeDeveloperName == CON_CLM.OSA_RECORD_TYPE_NAME) {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Field_API_Name__c = 'Apttus__Contract_Start_Date__c', Record_Type__c = 'OSA',Status_Category__c = CON_CLM.IN_AUTHORING));
                }
            } else if(statusCategory == CON_CLM.IN_SIGNATURES) {
                if(recordTypeDeveloperName == CON_CLM.PSA_RECORD_TYPE_NAME) {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Record_Type__c = CON_CLM.PSA_RECORD_TYPE_NAME,Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Status_Category__c = CON_CLM.IN_SIGNATURES));
                }
                if(recordTypeDeveloperName == 'MSA') {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Record_Type__c = 'MSA',Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Status_Category__c = CON_CLM.IN_SIGNATURES));
                }
            }   else if(statusCategory == CON_CLM.IN_BUDGETING) {
                if(recordTypeDeveloperName == CON_CLM.PSA_RECORD_TYPE_NAME) {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Record_Type__c = CON_CLM.PSA_RECORD_TYPE_NAME,Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Status_Category__c = CON_CLM.IN_BUDGETING, Status__c = CON_CLM.BUDGET_PREPARATION));
                }
                if(recordTypeDeveloperName == 'OSA') {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Record_Type__c = 'OSA',Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Status_Category__c = CON_CLM.IN_BUDGETING, Status__c = CON_CLM.BUDGET_PREPARATION));
                }
            }
            else if(statusCategory == CON_CLM.IN_EFFECT) {
                if(recordTypeDeveloperName == CON_CLM.RWSSOW_RECORD_TYPE_NAME) {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Field_API_Name__c = 'First_Patient_In_Date__c',Show_Different_Message_On_VF__c = false, Record_Type__c = 'RWSSOW',Status_Category__c = 'In Effect'));
                } 
                if(recordTypeDeveloperName == 'OSA') {
                    listOfTestMetaData.add(new CLM_FieldMapping_Validation__mdt(Field_API_Name__c = 'Apttus__Contract_Start_Date__c',Show_Different_Message_On_VF__c = false, Record_Type__c = 'OSA',Status_Category__c = 'In Effect'));
                } 
            }
            return listOfTestMetaData;
                       
        } else {
            return Database.query(factory.toSOQL());
        }
    }
}