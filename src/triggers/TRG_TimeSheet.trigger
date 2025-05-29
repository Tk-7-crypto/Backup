trigger TRG_TimeSheet on TimeSheet__c (before insert,before update,before delete) {
    EXT_CSM_Validator_Cls.setFromTimesheet();
}