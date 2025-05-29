/**
 * Version : 1.0
 * An apex controller that create supplemental record.
 */
public class CNT_CRM_Contract_CreateSupplemental {
    @AuraEnabled
    public static Contract getContractFromId(String recordId){
        Contract cntrt = new Contract();
        Set<String> fieldsSet = new Set<String>();
        List<Schema.FieldSetMember> contractFieldSet = Schema.SObjectType.Contract.fieldSets.ContractSupplementalRecordFields.getFields();
        for(Schema.FieldSetMember sfs : contractFieldSet){
            fieldsSet.add(sfs.getFieldPath());
        }
        List<Contract> contractList = new SLT_Contract().fetchContract(new Set<Id>{recordId}, fieldsSet);
        if(contractList.size() > 0){
            cntrt = contractList[0];
        }
        return cntrt;
    }
    @AuraEnabled
    public static List<String> getContractFieldSet(){
        List<String> fieldsList = new List<String>();
        Set<String> fieldsSet = new Set<String>();
        List<Schema.FieldSetMember> contractFieldSet = Schema.SObjectType.Contract.fieldSets.ContractSupplementalRecordFields.getFields();
        for(Schema.FieldSetMember sfs : contractFieldSet){
            fieldsSet.add(sfs.getFieldPath());
        }
        fieldsList.addAll(fieldsSet);
        return fieldsList;
    }
    @AuraEnabled
    public static List<recordTypeWrapper> fetchRecordTypes(){
        List<recordTypeWrapper> recordTypeWrapperList = new List<recordTypeWrapper>();
        recordTypeWrapper rtw = new recordTypeWrapper();
        rtw.recordTypeName = CON_CRM.CONTRACT_RECORD_TYPE_NAME_CHANGE_ORDER_GBO;
        rtw.recordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO;
        recordTypeWrapperList.add(rtw);
        rtw = new recordTypeWrapper();
        rtw.recordTypeName = CON_CRM.CONTRACT_RECORD_TYPE_NAME_WORK_ORDER_GBO;
        rtw.recordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_GBO;
        recordTypeWrapperList.add(rtw);
        rtw = new recordTypeWrapper();
        rtw.recordTypeName = CON_CRM.CONTRACT_RECORD_TYPE_NAME_THIRD_PARTY_AGREEMENT;
        rtw.recordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_THIRD_PARTY_AGREEMENT;
        recordTypeWrapperList.add(rtw);
        rtw = new recordTypeWrapper();
        rtw.recordTypeName = CON_CRM.CONTRACT_RECORD_TYPE_NAME_CHANGE_ORDER;
        rtw.recordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER;
        recordTypeWrapperList.add(rtw);
        rtw = new recordTypeWrapper();
        rtw.recordTypeName = CON_CRM.CONTRACT_RECORD_TYPE_NAME_WORK_ORDER_SALES_MEDICAL;
        rtw.recordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL;
        recordTypeWrapperList.add(rtw); 
        return recordTypeWrapperList;
    }
    public class recordTypeWrapper{
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public String recordTypeName;
    }
}