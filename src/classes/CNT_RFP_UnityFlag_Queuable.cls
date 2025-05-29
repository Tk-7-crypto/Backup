/**************************************************************************************************
* @Author:      Razia Khan 
* @Date:        17/03/2022
* @PageCode:    
* @CurErrCode: 
* @Description: IQVIACBEX-1804:This class will create custom object(Intake_Unity_Flag_Sync__c) record for each
*               object changes if its a part of fieldset.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***************************************************************************************************/
public class CNT_RFP_UnityFlag_Queuable implements Queueable, Database.AllowsCallouts {
     public String ObjectName;
     public List<Id> newObjectIdList;
    
     public CNT_RFP_UnityFlag_Queuable(String ObjectName, List<Id> newObjectIdList){ 
        this.ObjectName = ObjectName;
        this.newObjectIdList = newObjectIdList;
    }
    
	public void execute(QueueableContext qc) {
        processOutbound(ObjectName, newObjectIdList);
    }
    
    public void processOutbound(String ObjectName, List<Id> newObjectIdList) {
        List<Intake_Unity_Flag_Sync__c> unityFlagList = new List<Intake_Unity_Flag_Sync__c>();
        for(Id objId : newObjectIdList) {
             Intake_Unity_Flag_Sync__c unityFlagSync = new Intake_Unity_Flag_Sync__c();
             unityFlagSync.Mulesoft_Sync_Status__c = CON_CBEx.MULESOFT_SYNC_STATUS_PENDING;
             unityFlagSync.SObject_Id__c = objId;
             unityFlagSync.SObject_Type__c = ObjectName;
             unityFlagList.add(unityFlagSync);
        } 
        Database.insert(unityFlagList);
    }
}