/*
* Version : 1.0
* Description: Apex Controller for Field History lightning component.
*/
public with sharing class CNT_CRM_FieldsHistory {
    
    /*
     * This method is used to Fetch Field History records
     * @param Id recordId
     * @return List<Field_History__c>
	 */
    @AuraEnabled(cacheable = false)
    public static List<FieldHistoryWrapper> getFieldHistoryRecords(Id recordId) {
        Map<String,Map<String,String>> fieldPicklistMap = new Map<String,Map<String,String>>();
        Set<String> fieldSet = new Set<String> {'Name','New_Value_Long_Text__c', 'New_Value__c', 'Old_Value_Long_Text__c', 'Old_Value__c', 'Tracked_Field_API__c', 'Tracked_Field_Label__c', 'Tracked_Object__c', 'Tracked_Record_Id__c', 'Action_User__c', 'Action_Date_Time__c', 'Action_User__r.Name', 'Type__c'};
        List<Field_History__c> fieldHistoryRecords = new SLT_FieldHistory().getFieldHistory(fieldSet, recordId);
        
        Schema.SObjectType objectType = recordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();
        List<FieldHistoryWrapper> customhistory = new List<FieldHistoryWrapper>();
        for(SObject history : fieldHistoryRecords ){
            String newValue = '';
            String oldValue = '';
            if(string.valueof(history.get('Type__c')) == 'Long Text'){
                newValue = string.valueof(history.get('New_Value_Long_Text__c'));
                oldValue = string.valueof(history.get('Old_Value_Long_Text__c'));
            }else{
                newValue = string.valueof(history.get('New_Value__c'));
                oldValue = string.valueof(history.get('Old_Value__c'));
            }
            customhistory.add(new FieldHistoryWrapper(string.valueof(history.get('Tracked_Field_Label__c')), string.valueof(history.get('Tracked_Field_API__c')), oldValue, newValue,DateTime.valueOf(history.get('Action_Date_Time__c')), string.valueof(history.get('Action_User__c')), String.valueof(history.getSObject('Action_User__r').get('Name')), false, string.valueof(history.get('Type__c')))); 
        }
        List<FieldHistoryWrapper> Standardhistory = queryStandardHistory(recordId);
        if(Standardhistory != null){
            customhistory.addAll(Standardhistory);
        }
        Set<String> picklistFieldSet = new Set<String>();
        
        for(FieldHistoryWrapper history : customhistory){
            String fieldApiName = history.fieldApiName;
            if(history.datatype == 'Picklist' || history.datatype == 'DynamicEnum' || history.datatype == 'Picklist_Multi-Select'){
                fieldPicklistMap.put(fieldApiName, getPicklistlabel(objectName,fieldApiName));
            }
        }
        
        for(FieldHistoryWrapper fh:customhistory){
            if(fh.datatype == 'Currency' && fh.isStandardRecord == False){
                fh.newValue = fh.newValue != null ? formateCurrency(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? formateCurrency(fh.oldValue) : '';
            }else if(fh.datatype == 'DateTime'){
                fh.newValue = fh.newValue != null ? convertDateTimeinUserContext(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? convertDateTimeinUserContext(fh.oldValue) : '';
            }else if(fh.datatype == 'DateOnly'){
                fh.newValue = fh.newValue != null ? formatDate(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? formatDate(fh.oldValue) : '';
            }else if(fh.datatype == 'Double' || fh.datatype == 'Currency'){
                fh.newValue = fh.newValue != null ? formateNumber(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? formateNumber(fh.oldValue) : '';
            }else if(fh.datatype == 'Percent'){
                fh.newValue = fh.newValue != null ? formatePercent(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? formatePercent(fh.oldValue) : '';
            }else if(fh.datatype == 'Picklist' || fh.datatype == 'DynamicEnum'){
                fh.newValue = fh.newValue != null ? fieldPicklistMap.get(fh.fieldApiName).get(fh.newValue) : '';
                fh.oldValue = fh.oldValue != null ? fieldPicklistMap.get(fh.fieldApiName).get(fh.oldValue) : '';
            }else if(fh.datatype == 'Picklist_Multi-Select'){
                List<string> newPicklist = fh.newValue != null ? fh.newValue.split(';') : new List<String>();
                List<string> OldPicklist = fh.oldValue != null ? fh.oldValue.split(';') : new List<String>();
                List<String> newVal = new List<String>();
                for(String newStr : newPicklist){ 
                    newVal.add(fh.newValue != null ? fieldPicklistMap.get(fh.fieldApiName).get(newStr) : '');
                }
                fh.newValue = String.join(newVal,';');
                List<String> oldVal = new List<String>();
                for(String OldStr : OldPicklist){
                    oldVal.add(fh.oldValue != null ? fieldPicklistMap.get(fh.fieldApiName).get(OldStr) : '');
                }
                fh.oldValue =String.join(oldVal,';');
            } 
        }
        return customhistory;
    }

    
    /**
     * This method is used to Format DateTime in Users Context
     * @param String dt
     * @return String
	 **/
    private static String convertDateTimeinUserContext(String dt){
        DateTime gmtDatetime = DateTime.valueOf(dt);
        String userTimezone = UserInfo.getTimeZone().getID();
        DateTime userDatetime = gmtDatetime.addMinutes(TimeZone.getTimeZone(userTimezone).getOffset(gmtDatetime) / 60000);
        String formattedDatetime = userDatetime.format();
        return formattedDatetime;
    }
    
    /**
     * This method is used to Format DateTime in Users Context
     * @param String dateString
     * @return String
	 **/
    
    private static String formatDate(String dateString) {
        Date dt = Date.valueOf(dateString);
        String formattedDate = dt.format();
        return formattedDate;
    }
        
    /**
     * This method is used to Format Currency in Users Context
     * @param String amount
     * @return String
     **/
    private static String formateCurrency(String amount){
        String CurrencyCode = amount.substring(0, 3);
        amount = amount.substring(3, amount.length());
        String formattedAmount = formateNumber(amount); 
        return (CurrencyCode +' '+formattedAmount);
    }
    
    /**
     * This method is used to Format Number in Users Context
     * @param String numberString
     * @return String
     **/
    private static String formateNumber(String numberString){
        String num = numberString.Trim();
        num = (num=='') ? '0' : num;
        Decimal formatterNumber = Decimal.valueOf(num);
        return String.valueOf(formatterNumber.format());
    }
    
    /**
     * This method is used to Get Labels of Picklist
     * @param String ObjectApiName , String FieldApiName
     * @return String
	 **/  
    private static Map<String, String> getPicklistlabel(String objectApiName, String fieldApiName) {
        List<Schema.PicklistEntry> picklistEntries = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();
        Map<String,String> picklistValueMap = new Map<String,String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValueMap.put(picklistEntry.getValue(),picklistEntry.getLabel());
        }
        return picklistValueMap;
    }
    
    /*
     * This method is used to Format Percent Value in Users Context
     * @param String number1
     * @return String
	 **/
    private static string formatePercent(String number1){
        Decimal number2 = decimal.valueOf(number1);
        String formattedpercent = String.valueOf(number2.setScale(4))+ '%';
        return formattedpercent;
    }
    /*
     * This method is used to query on StandardHistory
     * @param Id recordId
     * @return List<FieldHistoryWrapper>
	 **/
    private static List<FieldHistoryWrapper> queryStandardHistory(Id recordId) {
        Schema.SObjectType objectType = recordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();
        String historyObjectName = objectName + 'History';
        String fieldHistoryObjectName = objectName + 'FieldHistory';
        String ParentId = objectName+'id'; 
        
        String selectedHistoryTable = determineHistoryTable(historyObjectName, fieldHistoryObjectName);
        if(selectedHistoryTable != null){
            String query = 'SELECT Field, OldValue, NewValue, CreatedById, CreatedDate, CreatedBy.Name, DataType FROM ' + selectedHistoryTable + ' WHERE ' + ParentId +'= :recordId AND DataType != \'EntityId\'';
            List<SObject> historyRecords = Database.query(query);
            List<FieldHistoryWrapper> standardhistory = new List<FieldHistoryWrapper>();
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            Map<String,String> standardFieldApiName = new Map<String ,String >();
            for(SObject history : historyRecords ){
                String fieldAPI = string.valueof(history.get('Field'));
                String stdDataType = string.valueof(history.get('DataType'));
                standardFieldApiName.put(stdDataType,fieldAPI);
                if(fieldAPI != 'created'){
                    Schema.DescribeFieldResult fieldResult = mfields.get(fieldAPI) != null ? mfields.get(fieldAPI).getDescribe() : NULL;
                    String fieldLabel = (fieldResult != null) ? fieldResult.getLabel(): fieldAPI;
                    standardhistory.add(new FieldHistoryWrapper(fieldLabel, fieldAPI, string.valueof(history.get('oldValue')), string.valueof(history.get('newValue')),DateTime.valueof(history.get('createdDate')), string.valueof(history.get('createdById')), String.valueof(history.getSObject('createdBy').get('Name')), true, string.valueof(history.get('DataType')))); 
                }
            }
            return standardhistory;
        }else {
            return null;
        }
    }
    /*
     * This method is used to Find the Standard History Object Name
     * @param String historyObjectName
     * @param String fieldHistoryObjectName
     * @return String
	 **/
    private static String determineHistoryTable(String historyObjectName, String fieldHistoryObjectName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (gd.containsKey(fieldHistoryObjectName)) {
            return fieldHistoryObjectName;
        }else if (gd.containsKey(historyObjectName)) {
            return historyObjectName;
        } else {
            return null;
        }
    }
    
    /**-- wrapper class to Show Field History Records--**/
    
    public class FieldHistoryWrapper {
        @AuraEnabled public String field { get; private set; }
        @AuraEnabled public String fieldApiName { get; private set; }
        @AuraEnabled public String oldValue { get; private set; }
        @AuraEnabled public String newValue { get; private set; }
        @AuraEnabled public DateTime createdDate { get; private set; }
        @AuraEnabled public String createdById { get; private set; }
        @AuraEnabled public String createdByName { get; private set; }
        @AuraEnabled public boolean isStandardRecord {get; private set;}
        @AuraEnabled public String datatype { get; private set; }
        
   /**
    * This method returns FieldHistoryWrapper  
    * @param String field
    * @param String fieldApiName
    * @param String oldValue
    * @param String newValue
    * @param string createdDate
    * @param String createdById
    * @param String createdByName
    * @param boolean isStandardRecord
    * @param string datatype
    * @return FieldHistoryWrapper
    */ 
        
        public FieldHistoryWrapper(String field,String fieldApiName, String oldValue, String newValue, DateTime createdDate, String createdById, String createdByName,boolean isStandardRecord,string datatype) {
            this.field = field;
            this.fieldApiName = fieldApiName;
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.createdDate = createdDate;
            this.createdById = createdById;
            this.createdByName = createdByName;
            this.isStandardRecord=isStandardRecord;
            this.datatype=datatype;
        }
    }
    
    /** This method is used to Get Object name
     * @param Id recordId
     * @return string
     **/
    @AuraEnabled(cacheable = true)
    public static string getObjectName (Id recordId){
        Schema.SObjectType objectType = recordId.getSObjectType();
        String objectName = objectType.getDescribe().getLabel();
        return objectName;
    }
}