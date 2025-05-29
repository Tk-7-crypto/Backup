/**************************************************************************************************
* @Author:      Razia Khan 
* @Date:        10/03/2022
* @PageCode:    
* @CurErrCode: 
* @Description: IQVIACBEX-1804:This is a class for triggering outbound that will send notification to mulesoft
                when fulfulling the criteria.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***************************************************************************************************/
public with sharing class CNT_RFP_IntakeUnityFlagSync {
	
    public static String objectAPIName;      
    public static Map<String, Object> mapOfChangeFields;
    public static Map<String, Object> mapOfOldFields;
    public static Map<Id, sObject> newMapVal;
    public static final Map<String, String> objectByFieldSetMap = new Map<String, String> {'Account' => 'Intake_Unity_Flag_Sync',
                                                                                            'Opportunity' => 'Intake_Unity_Flag_Sync',
                                                                                            'Bid_History__c'=> 'Intake_Unity_Flag_Sync',
                                                                                            'pse__Resource_Request__c' => 'Intake_Unity_Flag_Sync'
                                                                                          };
    /**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method is responsible for processing the sync logic between Salesforce and 
    *               Unity using mulesoft as middleware.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    public static void processSyncLogic(String objectAPIName, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        try {
            Boolean isTriggerOutbound = mapFields(objectAPIName, newMap, oldMap);
            if(isTriggerOutbound && CON_CRM_OpportunityRenewals.allowCbexQueueable) {
                //IQVIACBEXU-2251 enqueue the job in sync or async context based on existing queued jobs in the same transaction
                //As we can’t chain queueable jobs in an Apex test.
                //To avoid getting an error, we are checking if Apex is running in test context by calling Test.isRunningTest() before chaining jobs
                If(System.isQueueable() && !Test.isRunningTest()){
                    runprocessSyncLogicInFuture(objectAPIName, new List<Id>(newMap.keySet()));
                } else {
                    System.enqueueJob(new CNT_RFP_UnityFlag_Queuable(objectAPIName, new List<Id>(newMap.keySet())));
                }
            } 
        } 
        catch (Exception ex) {
             throw ex;
        }
    }  

    /**********************************************************************************************
    * @Author:      Ashish
    * @Date:        09/08/2022
    * @Description: IQVIACBEXU-2251:This method will enqueue the job in future context to finally
    *               create 'Intake unity flag sync' records
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    ***********************************************************************************************/
    @future
    public static void runprocessSyncLogicInFuture(String objectAPIName, List<Id> IdList) {
        System.enqueueJob(new CNT_RFP_UnityFlag_Queuable(objectAPIName, IdList));
    }
    
    /**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method will find whether the changed fields are part of field set or not?
    *               If yes, then only workflow outbound will be trigerred and those fields will be 
    *               send.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    public static Boolean mapFields(String ObjectName, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        Boolean triggerOutbound = false;
        if(objectByFieldSetMap != null && objectByFieldSetMap.get(ObjectName) != null) {
                List<Schema.FieldSetMember> objectFieldSet = readFieldSet(objectByFieldSetMap.get(ObjectName), ObjectName);
                Set<String> fielAPISet = new Set<String>();
                mapOfChangeFields = new Map<String, Object>();
                mapOfOldFields = new Map<String, Object>();
                if(objectFieldSet != null) {
                    for(Id objId : newMap.keySet()) {
                        for(Schema.FieldSetMember sf : objectFieldSet) {
                            String fieldAPI = sf.getFieldPath();                
                            object value = newMap.get(objId).get(fieldAPI);
                            if(value != oldMap.get(objId).get(fieldAPI)) {
                                 triggerOutbound = true;
                                 break;
                            }
                        }
                    }
                }
            }
        return triggerOutbound;           
    }
       
    /**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method will return list of fields wrt to each object.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/     
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        List<Schema.FieldSetMember> fieldSetMember = new List<Schema.FieldSetMember>();
        Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj;
        if(describeSObjectResultObj.FieldSets.getMap().get(fieldSetName) != null) {
           fieldSetMember = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName).getFields();  
        }

        return fieldSetMember;
    }                                                                                      
}