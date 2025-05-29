/**
 * This is Task Domain class.
 * version : 1.0
 */
public class DAO_Task extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Task>
     */
    public DAO_Task(List<Task> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Task(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Task trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Task.setTaskFields((List<Task>)Records, Null); 
        DAOH_Task.verifyTaskFields((List<Task>)Records, Null);
        DAOH_Task.populateCampaign((List<Task>)Records, null);
        DAOH_Task.markMQLTaskRejected((List<Task>)Records, null);
    }

    /**
     * This method is used for after insert of the Task trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Task.updateStatusforLogACallonCase((List<Task>)Records);
        DAOH_Task.saveAuditLogAfterInsertTask((List<Task>)Records); 
        DAOH_Task.saveAuditLogAfterInsertTask((List<Task>)Records); 
        DAOH_Task.setDisposationField((List<Task>)Records, null); 
        DAOH_Task.setNoOfMQLInCampaign((List<Task>)Records, null);
        DAOH_Task.setTypeFieldonTaskForOutlook((List<Task>)Records);
    } 
    
    /**
     * This method is used for before update of the Task trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Task.setTaskFields((List<Task>)Records, (Map<Id,Task>)existingRecords); 
        DAOH_Task.verifyTaskFields((List<Task>)Records, (Map<Id,Task>)existingRecords);
        DAOH_Task.populateCampaign((List<Task>)Records, (Map<Id,Task>)existingRecords);
        DAOH_Task.markMQLTaskRejected((List<Task>)Records, (Map<Id,Task>)existingRecords);
    }
    
    /**
     * This method is used for after update of the Task trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
   public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields=new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_TASK);

        if(fields!=null){ DAOH_Task.saveAuditLogAfterUpdateTaskFields((List<Task>)Records,(Map<Id,Task>)existingRecords,fields); }
        DAOH_Task.changeDispositionDetailFields((List<Task>)Records, (Map<Id, Task>)existingRecords);
        DAOH_Task.changeLeadOwner((List<Task>)Records, (Map<Id, Task>)existingRecords);
        DAOH_Task.setDisposationField((List<Task>)Records, (Map<Id,Task>)existingRecords); 
        DAOH_Task.setNoOfMQLInCampaign((List<Task>)Records, (Map<Id,Task>)existingRecords);
   }
    
    public override void onBeforeDelete() {
       String profileName=[Select Id,Name from Profile where Id=: UserInfo.getProfileId()].Name; 
       for (Task a : (List<Task>)Trigger.old)      
       {  
           if (a.WhatId != null && 'Case'.equalsIgnoreCase(String.valueOf(a.WhatId.getSObjectType())) && (profileName =='Service User' || profileName =='CSM Customer Community Plus Login User'))
              {
                  Trigger.oldMap.get(a.Id).addError('Cannot delete Task with related to Case');
              } 
      }
      
        DAOH_Task.verifyMQLTasksDeletion((List<Task>)Records);
  }
    public override void onAfterDelete(){
        DAOH_Task.countNoOfMqlAfterTaskDelete((List<Task>)Records);
    }
}