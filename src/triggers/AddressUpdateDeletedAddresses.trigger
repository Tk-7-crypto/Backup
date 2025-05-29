//  Trigger to set the account reference to null when addresses are marked for deletion
//  This means that addresses marked for deletion are not available for selection
//  when choosing addresses for a BNF

trigger AddressUpdateDeletedAddresses on Address__c (before insert, before update) 
{
    /**************************************************************************
    Update by : Himanshu parashar
    Date : 3 Feb 2012
    Skip account null for sending temp insertion of Address and send Request mail
    ****************************************************************************/
    Id mdmValidatedRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
    if(Global_Variables.RunAddressRequestTrigger)
    {
        for (Address__c A:Trigger.New)
        {
            if(A.RecordTypeId == mdmValidatedRecordTypeId) {
                //  Temporary fix to exclude dummy base customers created in SAP with codes above 700000
                if (A.SAP_Reference__c != null && A.SAP_Reference__c.isNumeric() && Integer.valueOf(A.SAP_Reference__c) >= 7000000)
                {
                    A.Marked_For_Deletion__c = true;
                }
                if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                    if (A.Marked_For_Deletion__c == true && A.Account__C != null)
                    {
                        A.Deleted_Account__c =  A.Account__C;
                        A.Account__c = null;
                    }
                }
            }
        }
    }
    
    //Added By Rakesh : 20 Jan 2014 : Issue-3463
    //***** START ******
    if( Trigger.isUpdate && Trigger.isBefore )
    {
        String profileName=[Select Id,Name from Profile where Id = :userinfo.getProfileId()].Name;
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        
        Boolean nonTpaFieldChange;
        List<Schema.FieldSetMember> fieldSet = SObjectType.Address__c.FieldSets.TPA_Fieldset.getFields();
        for (Address__c A:Trigger.New)
        {
            //just chack NON TPA field is chnaged or not. 
            nonTpaFieldChange = false;
            for(Schema.FieldSetMember field : fieldSet){
                if(A.get(field.getFieldPath()) != trigger.oldMap.get(A.Id).get(field.getFieldPath())){
                    nonTpaFieldChange = true;
                    break;
                }    
            }
            
            //updated by : Suman Sharma-- Date: 13 April, 2017 -- Issue-10718           
            if(nonTpaFieldChange && (A.RecordTypeId == mdmValidatedRecordTypeId || trigger.oldMap.get(A.Id).RecordTypeId == mdmValidatedRecordTypeId ) && !profileName.toLowerCase().contains('system administrator')){
                A.addError('Addresses cannot be edited in SFDC. Please request any changes through the MDM Global Helpdesk.');
            }else if(nonTpaFieldChange && A.RecordTypeId == CON_CRM.Unvalidated_Address_RecordId && !profileName.toLowerCase().contains('system administrator')
                && A.MDM_Validation_Status__c == 'Pending Validation' && trigger.oldMap.get(A.Id).MDM_Validation_Status__c == A.MDM_Validation_Status__c){
                    A.addError('Addresses cannot be edited in SFDC. Please request any changes through the MDM Global Helpdesk.');
            }
        }
    }
    
    if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
        if(Trigger.isInsert) {
            TGRH_Address.setAddressFields(Trigger.new, null);
        }
        if(Trigger.isUpdate) {
            TGRH_Address.setAddressFields(Trigger.new, Trigger.oldMap); 
        }
    }
    //**** END : Issue-3463  *****
   
    if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        TGRH_TPA_Address.setTpaVendorChecklist(Trigger.New, Trigger.oldMap == null? null: Trigger.oldMap);
    }
}