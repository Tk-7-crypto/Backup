/*
 * Version       : 1.0
 * Description   : Util Class for Sobject Operation
 */
public class UTL_Sobject {
    
    public Map<String, Schema.SObjectField> objFieldsMap;
    public sObjectType objectType;
    
    /**
     * constructor
     * @params  String objectName
     */    
    public UTL_Sobject(String sObjectName) {
        this.objectType = Schema.getGlobalDescribe().get(sObjectName);
        this.objFieldsMap = objectType.getDescribe().fields.getMap();
    }
    
    /**
     * util method used to get field detail of sobject
     * @params  List<String> fieldAPINameList
     * @return  List<ObjectFieldsWrapper>
     */
    public List<ObjectFieldsWrapper> getSobjectFieldDetails(List<String> fieldAPINameList) {
        Map<String,Territory_lookup__mdt> territoryLookupMap = new Map<String,Territory_lookup__mdt>();
        if(objectType == Product2.sObjectType) {
            territoryLookupMap = new SLT_TerritoryLookup().getTerritoryLookup();
        }
        List<ObjectFieldsWrapper> objFieldsWrapperList = new List<ObjectFieldsWrapper>();
        String fieldApiName;
        String fieldLabel;
        Schema.DisplayType fieldDataType;
        List<String> fieldValues;
        Map<String,String> fieldValuesMap;
        List<String> fieldNamesList = new List<String>(objFieldsMap.keySet());
        if(fieldAPINameList != null && fieldAPINameList.size() > 0) {
            fieldNamesList = fieldAPINameList;
        }
        Schema.DescribeFieldResult fieldResult;
        for(String fieldName : fieldNamesList) {
            fieldValues = new List<String>{'--None--'};
            fieldValuesMap = new Map<String,String>();
            fieldValuesMap.put('--None--', '--None--');
            fieldResult = objFieldsMap.get(fieldName).getDescribe();
            fieldApiName = fieldName.toLowerCase();
            fieldLabel = fieldResult.getLabel();
            fieldDataType = fieldResult.getType();
            if(fieldDataType == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> pickEntryList = fieldResult.getPickListValues();
                for(Schema.PicklistEntry pickEntry : pickEntryList) {
                    if(fieldName == CON_CRM.OPPORTUNITY_TERRITORY_FIELD_API) {
                        if(territoryLookupMap.containsKey(pickEntry.getValue())) {
                            fieldValues.add(pickEntry.getValue());
                        } 
                    }
                    else {
                        fieldValues.add(pickEntry.getValue());
                        fieldValuesMap.put(pickEntry.getValue(), pickEntry.getLabel());
                    }
                }
            }
            objFieldsWrapperList.add(new ObjectFieldsWrapper(fieldApiName, fieldLabel, fieldDataType, fieldValues, fieldValuesMap));
        }
        return objFieldsWrapperList;
    } 
    
    /**
     * Get sObject fields detail Map
     * @params  List<String> fieldAPINameList
     * @return  Map<String, ObjectFieldsWrapper>
     */
    public Map<String, ObjectFieldsWrapper> getSobjectFieldsDetailMap(List<String> fieldAPINameList) {
        Map<String, ObjectFieldsWrapper> fieldsDetailMap = new Map<String, ObjectFieldsWrapper>();
        List<String> fieldValues;
        Schema.DescribeFieldResult fieldResult; 
        Schema.DisplayType fieldDataType;
        for(String fieldName : fieldAPINameList) {
            fieldResult = objFieldsMap.get(fieldName).getDescribe();
            fieldDataType = fieldResult.getType();
            if(fieldDataType == Schema.DisplayType.PICKLIST) {
            	//fieldValues = new List<String>{'--None--'};
            	fieldValues = new List<String>();
                List<Schema.PicklistEntry> pickEntryList = fieldResult.getPickListValues();
                for(Schema.PicklistEntry pickEntry : pickEntryList) {
                    fieldValues.add(pickEntry.getValue());
                }
            }
            fieldsDetailMap.put(fieldName, new ObjectFieldsWrapper(fieldName, fieldResult.getLabel(), fieldDataType, fieldValues, fieldResult.getInlineHelpText()));
        }
        return fieldsDetailMap;
    }

    /**
     * util method used to get field detail of sobject
     * @params  List<String> fieldAPINameList
     * @return  List<ObjectFieldsWrapper>
     */
    public Map<String, String>  getFieldDataTypeByFieldAPIName() {
        Map<String, String> fieldDataTypeToFieldAPINameMap = new Map<String, String>();
        for(String fieldName : objFieldsMap.keySet()) {
            fieldDataTypeToFieldAPINameMap.put(fieldName, objFieldsMap.get(fieldName).getDescribe().getType().name().toLowerCase());
        }
        return fieldDataTypeToFieldAPINameMap;
    }
    
    /**
     * util method used to Custom Field Id by Field API NAME
     * @params  String objectNameWithoutUnderscore - object name without __c
     * @return  Map<String, String>
     */
    public Static Map<String, String> getCustomFieldByIds(String objectNameWithoutUnderscore) {
        Map<String, String> fieldApiNameToFieldId = new Map<String, String>();
        String objectName = objectNameWithoutUnderscore + '__c';
        if(fieldApiNameToFieldId.isEmpty()) {
            List<FieldDefinition> fielddefinitionList = [SELECT QualifiedApiName, durableId FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :objectName];
            for(FieldDefinition fd : fielddefinitionList) {
                fieldApiNameToFieldId.put(fd.QualifiedApiName, fd.durableid.split('\\.')[1]);
            }
        }
        System.debug('fieldApiNameToFieldId-----UTL_SObject--' + fieldApiNameToFieldId);
        return fieldApiNameToFieldId;
    }
}