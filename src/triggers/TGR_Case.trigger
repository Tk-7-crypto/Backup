/**
 @author Bhishmanand Gobin
 @Date Creation 11/7/2017
 @Date Modified 11/22/2017
 @description - Trigger is triggered every time after a case is updated, it check conditions and if conditions are met then resolutions milestone completion
                date is populated is system date as resolution completion date.

**/
/** trigger TGR_Case on Case (after update) {
            if (UserInfo.getUserType() == 'Standard'){
                DateTime completionDate = System.now();
                List<Id> updateCases = new List<Id>();
                List<Id> updateFirstResponse = new List<Id>();
                for (Case c : Trigger.new){
                    if (((c.isClosed == true)||(c.Status == 'closed'))&&((c.SlaStartDate <= completionDate)&&(c.SlaExitDate == null))){
                        updateCases.add(c.Id);
                    }
                
                if (updateCases.isEmpty() == false){
                    TGRH_MilestoneUtils.completeMilestone(updateCases, 'Resolution Time', completionDate);
                }
                
            }
        }
    }**/
trigger TGR_Case on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CSM_case_Trigger_Handler__c triggerControlSetting = CSM_case_Trigger_Handler__c.getInstance();
    if(EXT_CSM_Validator_Cls.hasFromTimesheet() && !UTL_ExecutionControl.stopTriggerExecution && triggerControlSetting != null && !triggerControlSetting.Disable_Case_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Case.class);
}