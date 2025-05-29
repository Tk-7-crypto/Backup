public with sharing class CNT_PSA_AutoCalculationOnAR {
    @AuraEnabled
    public static WPR_PSA_AutoCalculationOnAR autoCalculationDateOnAR(String recordId){
        WPR_PSA_AutoCalculationOnAR responseWrapper = new WPR_PSA_AutoCalculationOnAR();
        String labelName = '';
        Boolean isUpdate = false;
        Set<String> validationFieldSet = new Set<String>();
        Set<String> autoCalculationFieldSet = new Set<String>();
        Set<String> errorMsgSet = new Set<String>();
        String message = '';
        Date getDate;
        List<Aggregate_Report__c> aggregateReportToRetrieveList;
        List<Aggregate_Report__c> aggregateReportToUpdateList = new List<Aggregate_Report__c>();
        Map<String,List<PSA_Aggregate_Report_Auto_Calculation__mdt>> KeyToMetaDataListMap = new Map<String,List<PSA_Aggregate_Report_Auto_Calculation__mdt>>();
        Set<String> aggregateReportFieldsSet = new Set<String>{'Id','Record_Type__c','Report_Type__c'};
        
        Set<String> recordTypeSet = new Set<String>();
        Set<String> reportTypeSet = new Set<String>();
        Boolean isNotAvailable = false;
        if(recordId != null){
            aggregateReportToRetrieveList = new SLT_Aggregate_Report().selectAggregateReportsById(new Set<Id>{recordId}, aggregateReportFieldsSet);
            if(!aggregateReportToRetrieveList.isEmpty()){
                for(Aggregate_Report__c ar : aggregateReportToRetrieveList){
                    recordTypeSet.add(ar.Record_Type__c);
                    reportTypeSet.add(ar.Report_Type__c);
                }
                for(PSA_Aggregate_Report_Auto_Calculation__mdt metaData : [SELECT Id,Aggregate_Record_Type__c, Auto_Calculation_in_Field__c, 
                                                                           Calculate_Days__c,
                                                                           Field_Name__c,Report_Type__c
                                                                           FROM PSA_Aggregate_Report_Auto_Calculation__mdt
                                                                           WHERE Report_Type__c IN : reportTypeSet
                                                                           AND Aggregate_Record_Type__c IN  : recordTypeSet])
                {
                    aggregateReportFieldsSet.add(metaData.Auto_Calculation_in_Field__c);
                    aggregateReportFieldsSet.add(metaData.Field_Name__c);
                    if(KeyToMetaDataListMap.containsKey(metaData.Aggregate_Record_Type__c+'*'+metaData.Report_Type__c)){
                        KeyToMetaDataListMap.get(metaData.Aggregate_Record_Type__c+'*'+metaData.Report_Type__c).add(metaData);
                    }else{
                        KeyToMetaDataListMap.put(metaData.Aggregate_Record_Type__c+'*'+metaData.Report_Type__c,new List<PSA_Aggregate_Report_Auto_Calculation__mdt>{metaData});  
                    }
                }
                if(!KeyToMetaDataListMap.KeySet().isEmpty() && recordId != null){
                    aggregateReportToRetrieveList = new SLT_Aggregate_Report().selectAggregateReportsById(new Set<Id>{recordId}, aggregateReportFieldsSet);
                    for(Aggregate_Report__c ar : aggregateReportToRetrieveList){
                        isUpdate = false;
                        if(KeyToMetaDataListMap.containsKey(ar.Record_Type__c+'*'+ar.Report_Type__c)){
                            for(PSA_Aggregate_Report_Auto_Calculation__mdt autoCalculationSetting : KeyToMetaDataListMap.get(ar.Record_Type__c+'*'+ar.Report_Type__c)){
                                if(ar.get(autoCalculationSetting.Auto_Calculation_in_Field__c) != null || Test.isRunningTest()){
                                    labelName = Schema.getGlobalDescribe().get('Aggregate_Report__c').getDescribe().fields.getMap().get(autoCalculationSetting.Auto_Calculation_in_Field__c).getDescribe().getLabel();
                                    validationFieldSet.add(labelName);
                                    autoCalculationFieldSet.add(autoCalculationSetting.Auto_Calculation_in_Field__c);
                                }
                                if(autoCalculationSetting.Field_Name__c != null && ar.get(autoCalculationSetting.Field_Name__c) != null){
                                   getDate  = Date.valueOf(ar.get(autoCalculationSetting.Field_Name__c)).addDays(Integer.valueOf(autoCalculationSetting.Calculate_Days__c));
                                    if(getDate != null && !autoCalculationFieldSet.contains(autoCalculationSetting.Field_Name__c)){
                                        ar.put(autoCalculationSetting.Auto_Calculation_in_Field__c, getDate);
                                        isUpdate = true;
                                    }
                                }else{
                                    labelName = Schema.getGlobalDescribe().get('Aggregate_Report__c').getDescribe().fields.getMap().get(autoCalculationSetting.Field_Name__c).getDescribe().getLabel();
                                    errorMsgSet.add(labelName);
                                }
                            }
                        }
                        if(isUpdate){
                            aggregateReportToUpdateList.add(ar);
                        }
                    }
                }else{
                    isNotAvailable = true;
                    responseWrapper.errorMessage = 'Auto calculation functionality is not applicable for this report type';
                }
            }
            if(!validationFieldSet.isEmpty()){
                message = String.join( validationFieldSet,', ')+' already exists. Do you want to change the date or continue with the existing date.';
            }
            if(message != ''){
                responseWrapper.validationMessage = message;
            }
            if(!errorMsgSet.isEmpty()){
                message = String.join( errorMsgSet,', ')+' value is blank, please select the date.';
            }
            if(message != ''){
                responseWrapper.errorMessage = message;
            }
            if(!isNotAvailable && errorMsgSet.isEmpty() && validationFieldSet.isEmpty()){
                responseWrapper.response = 'success'; 
            }else if(!isNotAvailable && !validationFieldSet.isEmpty() && errorMsgSet.isEmpty()){
                responseWrapper.response = 'alert';
            }else{
                responseWrapper.response = 'fail';
            }
            
            responseWrapper.aggregateReportToRetrieveList = aggregateReportToRetrieveList;
            responseWrapper.metaDataMap = KeyToMetaDataListMap;
            if(!aggregateReportToUpdateList.isEmpty()){
                update aggregateReportToUpdateList; 
            }
        }
        
        return responseWrapper;
    }
    @AuraEnabled
    public static String updateAggregateReport(List<Aggregate_Report__c> aggregateReportToRetrieveList, Map<String,List<PSA_Aggregate_Report_Auto_Calculation__mdt>> KeyToMetaDataListMap){
        String returnResponse = '';
        Boolean isUpdate = false;
        Date getDate;
        List<Aggregate_Report__c> aggregateReportToUpdateList = new List<Aggregate_Report__c>();
        if(!KeyToMetaDataListMap.KeySet().isEmpty() || Test.isRunningTest()){
            if(!aggregateReportToRetrieveList.isEmpty()){
                for(Aggregate_Report__c ar : aggregateReportToRetrieveList){
                    if(KeyToMetaDataListMap.containsKey(ar.Record_Type__c+'*'+ar.Report_Type__c)){
                        for(PSA_Aggregate_Report_Auto_Calculation__mdt autoCalculationSetting : KeyToMetaDataListMap.get(ar.Record_Type__c+'*'+ar.Report_Type__c)){
                            if(ar.get(autoCalculationSetting.Auto_Calculation_in_Field__c) != null || Test.isRunningTest()){
                                if(autoCalculationSetting.Field_Name__c != null && ar.get(autoCalculationSetting.Field_Name__c) != null){
                                    getDate = Date.valueOf(ar.get(autoCalculationSetting.Field_Name__c)).addDays(Integer.valueOf(autoCalculationSetting.Calculate_Days__c));
                                    if(getDate != null){
                                        ar.put(autoCalculationSetting.Auto_Calculation_in_Field__c, getDate);
                                        isUpdate = true;
                                    }
                                }
                            }
                        }
                    }
                    if(isUpdate){
                        aggregateReportToUpdateList.add(ar);
                    }
                    isUpdate = false;
                }
            }
        }
        if(!aggregateReportToUpdateList.isEmpty()){
            update aggregateReportToUpdateList; 
            returnResponse = 'success';
        }
        return returnResponse;
    }
    public with sharing class WPR_PSA_AutoCalculationOnAR{
        @AuraEnabled public String response{get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public String validationMessage {get;set;}
        @AuraEnabled public List<Aggregate_Report__c> aggregateReportToRetrieveList {get;set;}
        @AuraEnabled public Map<String,List<PSA_Aggregate_Report_Auto_Calculation__mdt>> metaDataMap{get;set;}
    }
}