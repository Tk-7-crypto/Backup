/**
* Author : Ronak Mehta
* Created Date : 02-09-2024
* This trigger is used for opportunityTeamMember object.
*/
trigger TGR_OpportunitySplit on OpportunitySplit (before insert, before update) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_OpportunitySplit.class);
}