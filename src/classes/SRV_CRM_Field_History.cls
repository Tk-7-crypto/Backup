/**
 * Description:
 * This class provides functionality for tracking field history dynamically through custom metadata configuration.
 * It implements the singleton pattern to ensure only one instance is created per Salesforce object.
 * @Author: Pramod Kumar
 **/
public without sharing class SRV_CRM_Field_History {
    
    /**
     * Static map variable to maintain a mapping between Salesforce object names and their corresponding SRV_CRM_Field_History instances.
     * This map is used to implement the singleton pattern, ensuring only one instance is created per Salesforce object.
     **/
    private static Map<String, SRV_CRM_Field_History> instanceMap = new Map<String, SRV_CRM_Field_History>();
    
    //Instance variable to store the name of the Salesforce object for which field tracking is being performed.
    private String objectName;
    
    //Instance variable to store the list of tracked fields based on custom metadata configuration.
    private List<Field_History_Tracking_Field__mdt> trackedFields;
    
    // Instance variable to store the custom metadata object instance related to field tracking for the specified object.
    private Field_History_Tracking_Object__mdt ftObject;
    
    // Instance variable to store Long Text Literal. 
    private static String TYPE_LONG_TEXT = 'Long Text';
    
    // Instance variable to store Currency Literal.     
    private static String TYPE_CURRENCY = 'Currency';   
    
    // Instance variable to store Lookup Literal.     
    private static String TYPE_LOOKUP = 'Lookup';   
    
    // Instance variable to store CurrencyIsoCode Literal.     
    private static String TYPE_CurrencyIsoCode = 'CurrencyIsoCode';
    
    /**
     * Static method to get or create an instance of the SRV_CRM_Field_History class for a specific Salesforce object.
     * @param objectName - The name of the Salesforce object for which an instance is requested.
     * @return SRV_CRM_Field_History - The instance of the SRV_CRM_Field_History class.
     **/
    public static SRV_CRM_Field_History getInstance(String objectName) {
        SRV_CRM_Field_History instance;
        
        if(instanceMap.get(objectName) != null) {
            instance = instanceMap.get(objectName);
        } else {
            instance = new SRV_CRM_Field_History(objectName);
            instanceMap.put(objectName, instance);
        }
        return instance;
    }
    
    /**
     * Constructor for the SRV_CRM_Field_History class.
     * Initializes the instance with the provided objectName and loads tracking fields if applicable.
     * @param objectName - The name of the Salesforce object for which field tracking is being performed.
     **/
    private SRV_CRM_Field_History(String objectName) {
        this.objectName = objectName;
        Datetime currentDateTime = System.now();
        ftObject = Field_History_Tracking_Object__mdt.getInstance(objectName);
        if (ftObject != null && ftObject.Is_Active__c) {
            
            if(ftObject.Tracking_Start_Date__c != null && ftObject.Tracking_End_Date__c != null && currentDateTime >= ftObject.Tracking_Start_Date__c && currentDateTime <= ftObject.Tracking_End_Date__c) {
                getTrackingFields();
            }
            
            if(ftObject.Tracking_Start_Date__c != null && ftObject.Tracking_End_Date__c == null && currentDateTime >= ftObject.Tracking_Start_Date__c) {
                getTrackingFields();
            }
            
            if(ftObject.Tracking_Start_Date__c == null  && ftObject.Tracking_End_Date__c != null && currentDateTime <= ftObject.Tracking_End_Date__c) {
                getTrackingFields();
            } 
            
            if(ftObject.Tracking_Start_Date__c == null  && ftObject.Tracking_End_Date__c == null) {
                getTrackingFields();
            }
        }
    }
    
    //Private method to load tracked fields based on the custom metadata configuration.
    private void getTrackingFields() {
        String ftobjectid = ftObject.Id;
        Set<String> trackedfieldSet = new Set<String> {'Field__c', 'Field_Label__c', 'Type__c'};
        String condition = 'Field_History_Tracking_Object__c = :ftobjectid AND Is_Active__c = TRUE';
        trackedFields = new SLT_FieldHistoryTrackingFields().TrackingFields(trackedfieldSet,condition,ftobjectid);
    }
    
    /**
     * Public method to save field history records based on changes in records.
     * @param newRecords - List of new records.
     * @param oldMap - Map of old records (before the changes).
     **/
    public void saveFieldHistories( List<SObject> newRecords, Map<Id, SObject> oldMap) {
        createFieldHistories(UserInfo.getUserId(), System.now(), newRecords, oldMap);
    }
    
    /**
     * Public method to save field history records based on the provided request payload.
     * @param requestPayload - The payload containing information for creating field history records.
     **/
    public void saveFieldHistories( WSC_CRM_Field_History.RequestPayload requestPayload) {
        createFieldHistories(requestPayload.getActionUserId(), requestPayload.getActionTime(), requestPayload.getNewRecords(), requestPayload.getOldMap());
    } 
    
    /**
     * Private method to create field history records based on tracking configuration and changes in records.
     * @param actionUser - The user performing the action.
     * @param actionTime - The timestamp when the action occurred.
     * @param newRecords - List of new records.
     * @param oldMap - Map of old records (before the changes).
     **/
    private void createFieldHistories(String actionUser, Datetime actionTime, List<SObject> newRecords, Map<Id, SObject> oldMap) {
        if (ftObject != null && trackedFields != null && !trackedFields.isEmpty()) {
            List<Field_History__c> fieldHistories = new List<Field_History__c>();
            Boolean isNew = oldMap == null ? true : false; 
            for (SObject record : newRecords) {
                SObject oldRecord = oldMap?.get(record.Id);
                for (Field_History_Tracking_Field__mdt trackedField : trackedFields) {
                    if (String.isNotBlank(trackedField.Field__c) && ((isNew && record.get(trackedField.Field__c) != null) ||  (!isNew && oldRecord.get(trackedField.Field__c) != record.get(trackedField.Field__c)) )) {
                        Field_History__c history = new Field_History__c();
                        history.Tracked_Object__c = objectName;
                        history.Tracked_Field_Label__c = trackedField.Field_Label__c;
                        history.Tracked_Field_API__c = trackedField.Field__c;
                        history.Tracked_Record_Id__c = record.Id;
                        history.Action_User__c = actionUser;
                        history.Action_Date_Time__c = actionTime;
                        history.Type__c = trackedField.Type__c;
                        
                        if(trackedField.Type__c == TYPE_LONG_TEXT) {
                            history.New_Value_Long_Text__c = String.valueOf(record.get(trackedField.Field__c));
                            history.Old_Value_Long_Text__c = String.valueOf(oldRecord?.get(trackedField.Field__c));
                        } else if(trackedField.Type__c == TYPE_CURRENCY){
                            history.New_Value__c = (record.get(trackedField.Field__c) != null) ? (record.get(TYPE_CurrencyIsoCode) + ' ' + String.valueOf(record.get(trackedField.Field__c))?.substring(0, String.valueOf(record.get(trackedField.Field__c)).length())) : '';
                            history.Old_Value__c =  (oldRecord?.get(trackedField.Field__c) != null)  ? (oldRecord.get(TYPE_CurrencyIsoCode) + ' ' + String.valueOf(oldRecord?.get(trackedField.Field__c))?.substring(0, String.valueOf(oldRecord?.get(trackedField.Field__c)).length())) : '';
                        } else if(trackedField.Type__c == TYPE_LOOKUP){
                            history.New_Value__c = getRecordIdName(String.valueOf(record.get(trackedField.Field__c))?.substring(0, String.valueOf(record.get(trackedField.Field__c)).length()));
                            history.Old_Value__c = getRecordIdName(String.valueOf(oldRecord?.get(trackedField.Field__c))?.substring(0, String.valueOf(oldRecord?.get(trackedField.Field__c)).length()));
                        } else {
                            history.New_Value__c = String.valueOf(record.get(trackedField.Field__c))?.substring(0, String.valueOf(record.get(trackedField.Field__c)).length());
                            history.Old_Value__c = String.valueOf(oldRecord?.get(trackedField.Field__c))?.substring(0, String.valueOf(oldRecord?.get(trackedField.Field__c)).length());
                        }
                        fieldHistories.add(history);
                    }
                }
            }
            
            if(fieldHistories.size()>0){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[]{ Field_History__c.SobjectType });
                uow.registerNew(fieldHistories);
                try {
                    uow.commitWork();
                } catch(Exception ex) {
                    String exception_List = ex.getStackTraceString();
                    Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
                    apexErrorLog.Running_User__c = UserInfo.getUserId();
                    apexErrorLog.Object__c = this.objectName;
                    apexErrorLog.Error_Message__c = ex.getTypeName() +' : '+ex.getStackTraceString();
                    insert apexErrorLog;
                    sendEmailOnException(ex);
                } 
            }
        }
    }
    
    /*
     * This method send mail when exception occurs
     **/  
    @TestVisible
    private static void sendEmailOnException(Exception ex){
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        CRM_Config__c CRMConfig = CRM_Config__c.getOrgDefaults();
        List<String> exceptionEmailList = CRMConfig.Field_History_Exception_Email__c.split(':');
        String[] toAddresses = exceptionEmailList;
        message.toEmails = toAddresses;
        message.subject = ex.getMessage();
        message.staticContent = ex.getTypeName() +' : '+ex.getStackTraceString();
        messageList.add(message);
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
    
    /**
     * Public helper method for Getting the Name Of lookup field Id.
     * @param recordId - Old and New lookup field Id.
     **/
    @TestVisible
    private static string getRecordIdName(Id recordId){
        String recordname = new SLT_FieldHistoryTrackingFields().getRecordIdName(recordId);
        return recordname;
    }
}