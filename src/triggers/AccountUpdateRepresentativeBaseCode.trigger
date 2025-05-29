trigger AccountUpdateRepresentativeBaseCode on Address__c (after update, after insert, after delete) 
{
    Set <Id> Account_Id_Set = new Set <Id>();
    Id mdmValidatedRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
    List <Address__c> Address_Array = new List <Address__c>();
    if (Trigger.isUpdate || Trigger.isInsert)
    {
        Address_Array = Trigger.New;
    }
    else
    {
        Address_Array = Trigger.Old;
    }
    for (Address__c A:Address_Array)
    {
        if(A.recordTypeId == mdmValidatedRecordTypeId) {
            Account_Id_Set.add(A.Account__c);   
        }        
    }
    Account_MDM_Extension.UpdateRepresentativeBaseCode(Account_Id_Set);
    if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
        if(Trigger.isInsert) {
            TGRH_Address.setAddressApprovalStatus(Trigger.new, null); 
        }
        if(Trigger.isUpdate) {
            TGRH_Address.setAddressApprovalStatus(Trigger.new, Trigger.oldMap); 
        }
    }

    if(Trigger.IsAfter && (Trigger.IsUpdate || Trigger.IsInsert) && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        TGRH_TPA_Address.updateNewParentMapping(Trigger.New, Trigger.oldMap == null? null: Trigger.oldMap); 
    }
}