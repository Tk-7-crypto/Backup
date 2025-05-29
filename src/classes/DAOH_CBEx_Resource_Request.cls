public class DAOH_CBEx_Resource_Request {
	
    /**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method is responsible for sending the new and old field values for further
    *               implementation of sync logic between Salesforce and Unity using mulesoft as 
    *               middleware.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    public static void setUnityFlagSyncMechanism(Map<Id, pse__Resource_Request__c> newMap, Map<Id, pse__Resource_Request__c> oldMap) {
        CNT_RFP_IntakeUnityFlagSync.processSyncLogic(CON_CBEx.RESOURCE_REQUEST_OBJECT, newMap, oldMap);
    }
}