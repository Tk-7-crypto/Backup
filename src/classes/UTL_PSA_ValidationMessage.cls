public with sharing class UTL_PSA_ValidationMessage{
    
    
    /**
    * This method is used to return Fields 
    * @param isFromTrigger
    * @param sObjectName
    * @param isNewParent
    * @param List< SObject> sObjectList
    * @return Set<String> addErrorAndGenerate
    */
    public static List<String> addErrorAndGenerate(Boolean isFromTrigger,
                                                   String sObjectName,
                                                   Boolean isNewParent,
                                                   List< SObject> sObjectList,
                                                   Boolean isChangesCompleteStatus){
        Integer maxLimitOfChild = 0;
        
        //Boolean Variable
        Boolean isAvoidChildCondition = false;
        Boolean isError = false;
        Boolean isAddStyling = false;
        Boolean isRecordNameFlag = false;
        Boolean isAddFlag = false;
        Boolean isEmptyParentFields = false;
        
        // String variable
        String queryChildStr;
        String queryChildStr1;
        String triggerFieldLabels='';
        String setUniqueNumber = '';
        String keyRequiredChild = '';
        String recordName ='';
        String strHeading;
        String labelName;
        String childObApiName ='';                                               
        
        // Sets
        Set<String> parentIdsSet = new Set<String>();
        Set<Id> childIdsSet =  new Set<Id>();
        Set<String> lrSearchStrategyRelationshipFieldsSet = new Set<String>{'Name', 'Search_Strategy_M__c'};
            
        //Lists
        List<String> htmlOfFieldLabelsList = new List<String>();
        List<String> validationfieldsList;
        List<String> childObFieldsList;
        List<String> setOfFieldAPINamesList = new List<String>();
        List<String> conditionMsgList = new List<String>();
        List<String> addAtLeastMsgList = new List<String>();
        List<String> addChildFieldsList = new List<String>();
        List<String> addParentFieldsList = new List<String>();
        List<String> strFieldsList = new List<String>();
        List<LR_Search_Strategy_Relationship__c> lrSearchStrategyList = new List<LR_Search_Strategy_Relationship__c>();
        List<SObject> childObjectList = new List<SObject>();
        List<String> parentValidationErrorList = new List<String>();
        List<Validation_Mapping_Generate_Message__c> fieldMappingRecordList = Validation_Mapping_Generate_Message__c.getAll().values();
        
        //Maps
        Map<String, Set<String>> uniqueNumberToChildMap = new Map< String, Set<String>>();
        Map<String, List< String>> childObToFieldsMap = new Map<String, List<String>>();
        Map<String, List<String >> uniqueNumberToConditionFieldMap = new  Map<String, List<String>>();
        Map<String, String > conditionFieldToConditionValueMap = new  Map<String, String>();
        Map<String, List<String>> conditionValueToListFieldsApiMap = new  Map<String, List<String>>();
        Map<String, Boolean> requiredChildMap = new Map<String, Boolean>();
        Map<String, List<SObject>> childNameToChildRecordsMap = new Map<String, List<SObject>>();
        
        for(SObject sOj : sObjectList){
            parentIdsSet.add(sOj.Id);
        }
        for(Validation_Mapping_Generate_Message__c fieldMappingRecord : fieldMappingRecordList){
            if(sObjectName == fieldMappingRecord.Object_Name__c){
                if(fieldMappingRecord.Required_Parent_Fields__c != null){
                    validationfieldsList = fieldMappingRecord.Required_Parent_Fields__c.split(',');
                }
                if(fieldMappingRecord.Required_Child_Fields__c != null){
                    childObFieldsList = fieldMappingRecord.Required_Child_Fields__c.split(',');
                }
                if(fieldMappingRecord.Required_Child_Objects__c != null && fieldMappingRecord.Unique_Number__c != null){
                    String keyUniqueNumberAndChildObject = fieldMappingRecord.Unique_Number__c+'-'+fieldMappingRecord.Required_Child_Objects__c;
                    if(childObToFieldsMap.containsKey(keyUniqueNumberAndChildObject)){
                        List<String> existingChildFields=  childObToFieldsMap.get(keyUniqueNumberAndChildObject);
                        for(String field : childObFieldsList){
                            if(!existingChildFields.contains(field)){
                                addChildFieldsList.add(field);
                            }
                        }
                        if(addChildFieldsList.size() > 0){
                            childObToFieldsMap.get(keyUniqueNumberAndChildObject).addAll(addChildFieldsList);
                        }
                    }else{
                        childObToFieldsMap.put(keyUniqueNumberAndChildObject, childObFieldsList);
                    }
                }
                if(uniqueNumberToConditionFieldMap.containsKey(fieldMappingRecord.Unique_Number__c)){
                    uniqueNumberToConditionFieldMap.get(fieldMappingRecord.Unique_Number__c).add(fieldMappingRecord.Parent_Condition_Field_Api_Name__c);
                }else{
                    uniqueNumberToConditionFieldMap.put(fieldMappingRecord.Unique_Number__c, new List<String>{fieldMappingRecord.Parent_Condition_Field_Api_Name__c});
                }
                if(uniqueNumberToChildMap.containsKey(fieldMappingRecord.Unique_Number__c)){
                    uniqueNumberToChildMap.get(fieldMappingRecord.Unique_Number__c).add(fieldMappingRecord.Required_Child_Objects__c);
                }else{
                    uniqueNumberToChildMap.put(fieldMappingRecord.Unique_Number__c, new Set<String>{fieldMappingRecord.Required_Child_Objects__c});
                }
                
                if(fieldMappingRecord.Unique_Number__c != null && fieldMappingRecord.Required_Child_Objects__c != null && fieldMappingRecord.Is_Required_Child__c == TRUE){
                    keyRequiredChild = fieldMappingRecord.Unique_Number__c+'-'+fieldMappingRecord.Required_Child_Objects__c;
                    requiredChildMap.put(keyRequiredChild, fieldMappingRecord.Is_Required_Child__c);
                }
                
                if(fieldMappingRecord.Unique_Number__c != null){
                    String uniqueKey = fieldMappingRecord.Unique_Number__c +'-'+fieldMappingRecord.Parent_Condition_Field_Api_Name__c;
                    conditionFieldToConditionValueMap.put(uniqueKey, fieldMappingRecord.Parent_Condition_Field_Value__c);
                    String uniKeyOfuniNumberToParentFieldValue = fieldMappingRecord.Unique_Number__c+'-'+fieldMappingRecord.Parent_Condition_Field_Value__c;
                    if(conditionValueToListFieldsApiMap.containsKey(uniKeyOfuniNumberToParentFieldValue)){
                        List<String> existingParentFields=  conditionValueToListFieldsApiMap.get(uniKeyOfuniNumberToParentFieldValue);
                        for(String field : validationfieldsList){
                            if(!existingParentFields.contains(field)){
                                addParentFieldsList.add(field);
                            }
                        }
                        if(addParentFieldsList.size() > 0){
                            conditionValueToListFieldsApiMap.get(uniKeyOfuniNumberToParentFieldValue).addAll(addParentFieldsList);
                        }
                        conditionValueToListFieldsApiMap.get(uniKeyOfuniNumberToParentFieldValue).addAll(validationfieldsList);
                    }else{
                        conditionValueToListFieldsApiMap.put(uniKeyOfuniNumberToParentFieldValue, validationfieldsList);
                    }
                }
            }
        }
        
        if(uniqueNumberToConditionFieldMap.size() > 0 
           && conditionFieldToConditionValueMap.size() > 0 
           && conditionValueToListFieldsApiMap.size() > 0){
               Integer matchConditionCount;
               for(SObject obj : sObjectList){
                   for(String uniqueNumber : uniqueNumberToConditionFieldMap.keySet()){
                       matchConditionCount = 0;
                       for(String conditionField : uniqueNumberToConditionFieldMap.get(uniqueNumber)){
                           String key = uniqueNumber+'-'+conditionField;
                           if(conditionFieldToConditionValueMap.containsKey(key) 
                              && conditionFieldToConditionValueMap.get(key) != null){
                                  if(conditionFieldToConditionValueMap.containsKey(key) && conditionFieldToConditionValueMap.get(key) != null){
                                      if(conditionValueToListFieldsApiMap.containsKey(uniqueNumber+'-'+conditionFieldToConditionValueMap.get(key))
                                         && conditionValueToListFieldsApiMap.get(uniqueNumber+'-'+conditionFieldToConditionValueMap.get(key)) != null){
                                             if(obj.get(conditionField) != null){
                                                 List< String > multipleValue  =  conditionFieldToConditionValueMap.get(key).split(',');
                                                 for(String parentConditionValue : multipleValue){
                                                     if(parentConditionValue.equalsIgnoreCase(String.valueOf(obj.get(conditionField)))){
                                                         matchConditionCount ++;
                                                         setUniqueNumber = uniqueNumber;
                                                         setOfFieldAPINamesList.addAll(conditionValueToListFieldsApiMap.get(uniqueNumber+'-'+conditionFieldToConditionValueMap.get(key)));
                                                         if(!conditionMsgList.contains(conditionField.remove('__c').replace('_',' ')+' is set as '+parentConditionValue)){
                                                            conditionMsgList.add(conditionField.remove('__c').replace('_',' ')+' is set as '+parentConditionValue); 
                                                         }
                                                         break;
                                                     } 
                                                 }
                                             }
                                         }
                                  }
                              }
                       }
                       If(uniqueNumberToConditionFieldMap.containsKey(setUniqueNumber) 
                          && uniqueNumberToConditionFieldMap.get(setUniqueNumber) != null){
                              if(uniqueNumberToConditionFieldMap.get(setUniqueNumber).size() == matchConditionCount){
                                  isAvoidChildCondition = true;
                                  break;
                              }else{
                                  setOfFieldAPINamesList.clear(); 
                              }
                          }else{
                              setOfFieldAPINamesList.clear(); 
                          }
                   }
               } 
           }
       	addAtLeastMsgList.add('You cannot Save '+sObjectName.remove('__c')+' as there is no ');
        if(sObjectName == CON_PSA.LR_PROJECT_OVERVIEW_OBJECT_API_NAME && isNewParent &&  isAvoidChildCondition){
            lrSearchStrategyList = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipFromLrIdLimit(parentIdsSet, lrSearchStrategyRelationshipFieldsSet, 1);
            for(LR_Search_Strategy_Relationship__c sChild : lrSearchStrategyList){
                childIdsSet.add(sChild.Search_Strategy_M__c);
            }
            
        }
        if(isNewParent &&  isAvoidChildCondition){
            if(childObToFieldsMap.size() > 0){
                if(childObToFieldsMap.containsKey(setUniqueNumber+'-Search_Strategy__c')){
                    if(isChangesCompleteStatus){
                        childObjectList.addAll(new SLT_Search_Strategy().getSearchStrategiesByIds(childIdsSet,new Set<String>(childObToFieldsMap.get(setUniqueNumber+'-Search_Strategy__c')))); 
                    }else{
                        childObjectList.addAll(new SLT_PSA_ArchiveSearchStrategy().getArchiveSSByLRID(new Set<Id>((List<Id>)new List<String>(parentIdsSet )),new Set<String>(childObToFieldsMap.get(setUniqueNumber+'-Search_Strategy__c'))));  
                    }
               }
                if(childObToFieldsMap.containsKey(setUniqueNumber+'-CFI_Meetings__c')){
                    childObjectList.addAll(new SLT_CFI_Meetings().getCFIMeetingsBylRProjectOverViewIds(parentIdsSet,new Set<String>(childObToFieldsMap.get(setUniqueNumber+'-CFI_Meetings__c')))); 
                }
                if(uniqueNumberToChildMap.containsKey(setUniqueNumber) && uniqueNumberToChildMap.get(setUniqueNumber) != null){
                    for(String childOb : uniqueNumberToChildMap.get(setUniqueNumber)){
                        String keyUniqueField = setUniqueNumber+'-'+childOb;
                        if(childObToFieldsMap.containsKey(keyUniqueField) && childObToFieldsMap.get(keyUniqueField) != null){
                            if(childObjectList.size() > 0){
                                for(Sobject sOb : childObjectList){
                                    childObApiName = sOb.Id.getSObjectType().getDescribe().getName();
                                    if(childOb == childObApiName && requiredChildMap.get(setUniqueNumber+'-'+childOb) == TRUE){
                                        if(childNameToChildRecordsMap.containsKey(childOb)){
                                            childNameToChildRecordsMap.get(childOb).add(sOb); 
                                        }else{
                                            childNameToChildRecordsMap.put(childOb, new List<sObject>{sOb}); 
                                        } 
                                    }
                                }
                            }
                            if(requiredChildMap.get(setUniqueNumber+'-'+childOb) == TRUE && !childNameToChildRecordsMap.containsKey(childOb)){
                                isError = true;
                                isAddStyling = true;
                                addAtLeastMsgList.add(childOb.remove('__c'));
                            }
                        }
                    }
                }
                if(isAddStyling){
                    triggerFieldLabels+= String.join( addAtLeastMsgList,', ')+' created, '+String.join(conditionMsgList ,', ')+', Please create one to save.'; 
                }
                if(childNameToChildRecordsMap.size() > 0 && setOfFieldAPINamesList.size() > 0){
                    for(String childObName : childNameToChildRecordsMap.keySet()){
                        if(childNameToChildRecordsMap.get(childObName) != null){
                            if(!isAddStyling){
                               strHeading = 'The following fields cannot empty in '+childObName.remove('__c')+' :-'; 
                            }else{
                               strHeading = '********************************************The following fields cannot empty in '+childObName.remove('__c')+' :------------------------------';  
                            }
                            for(SObject childObj : childNameToChildRecordsMap.get(childObName)){
                                if(childObToFieldsMap.containsKey(setUniqueNumber+'-'+childObName) && childObToFieldsMap.get(setUniqueNumber+'-'+childObName) != null){
                                    for(String childFieldApiName : childObToFieldsMap.get(setUniqueNumber+'-'+childObName)){
                                        if(childObj.get(childFieldApiName) == null || childObj.get(childFieldApiName) == false || childObj.get(childFieldApiName) == ''){
                                            if(!isRecordNameFlag){
                                                if(String.valueOf(childObj.get('Name')) != null){
                                                    recordName = String.valueOf(childObj.get('Name'));
                                                    strFieldsList.add('Record Name : '+recordName); 
                                                }
                                            }
                                            labelName = Schema.getGlobalDescribe().get(childObName).getDescribe().fields.getMap().get(childFieldApiName).getDescribe().getLabel();
                                            if(isFromTrigger){
                                                isError = true;
                                                isAddFlag = true;
                                                isRecordNameFlag = true;
                                                if(!strFieldsList.contains(labelName)){
                                                    strFieldsList.add(labelName); 
                                                }
                                            }else {
                                                htmlOfFieldLabelsList.add('- '+labelName);
                                            }
                                        }
                                    }
                                    recordName = '';
                                    isRecordNameFlag = false;
                                }
                            }
                            if(isAddFlag == true){
                                triggerFieldLabels += strHeading+String.join(strFieldsList ,', ')+'*******************************';
                            }
                            isAddFlag = false;
                            strHeading = ' ';
                            strFieldsList = new List<String>();
                        }
                    }
                }
            }
        }
        parentValidationErrorList.add(' The following fields cannot empty in '+sObjectName.remove('__c')+' :--');
        if(sObjectList.size() > 0){
            for(SObject obj : sObjectList){
                for(String fieldName: setOfFieldAPINamesList){
                    if(obj.get(fieldName) == null || obj.get(fieldName) == false || obj.get(fieldName) == ''){
                        labelName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                        if(isFromTrigger) {
                            isError = true;
                            isEmptyParentFields = true;
                            if(!parentValidationErrorList.contains(labelName)){
                               parentValidationErrorList.add(labelName); 
                            }
                        }else{
                            htmlOfFieldLabelsList.add(labelName);
                        }
                    }
                }
                if(isError){
                    if(isEmptyParentFields){
                        triggerFieldLabels+= String.join(parentValidationErrorList ,', ');
                    }
                    obj.addError(new UTL_PSA_ValidationMessage_Exception(triggerFieldLabels),false);
                }
            }
        }
        return setOfFieldAPINamesList ;
    }
    public class UTL_PSA_ValidationMessage_Exception extends Exception {}
}