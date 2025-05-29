trigger TGR_TpaRequest on TPA_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_TpaRequest.class);
    /* system.debug('before update debug00::::');
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                DAOH_TpaRequest.onBeforeInsert(Trigger.New);
            }
        }
        else if(Trigger.isUpdate) {system.debug('before update debug::::');
            if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {system.debug('before update debug0::::');
                DAOH_TpaRequest.onBeforeUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
            }
        }
        else if(Trigger.isDelete) {
            if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                DAOH_TpaRequest.onBeforeDelete(Trigger.New);
            }
        }
    }
    else if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                DAOH_TpaRequest.onAfterInsert(Trigger.New);
            }
        }
        else if(Trigger.isUpdate) {
            if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
                DAOH_TpaRequest.onAfterUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
            }
        }
    }*/
}