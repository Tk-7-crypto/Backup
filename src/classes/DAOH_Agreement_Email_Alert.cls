/**
* This is Agreement Email Alert trigger handler class.
* version : 1.0
*/
public class DAOH_Agreement_Email_Alert {
    
    /**
     * This Method is used to check user permission for Record Update
     * @params List<Agreement_Email_Alert__c> newEmailAlert
     * @params Map<Id, Agreement_Email_Alert__c> oldMap
     * @return void
     */ 
    public static void checkUserPermissionForUpdate(List<Agreement_Email_Alert__c> newEmailAlert, Map<Id, Agreement_Email_Alert__c> oldMap){
        Id userId = UserInfo.getUserId();
        String userEmail = UserInfo.getUserEmail();
        Id profileId = UserInfo.getProfileId();
        String profileName = new SLT_Profile().selectById(new Set<Id>{profileId})[0].Name;
        List<PermissionSetAssignment> permissionNameByUser = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(new Set<String>{'Permissionset.Name'}, new Set<Id>{userId}, 'Agreement_Email_Alert_Global_Edit');
        Set<String> adminProfiles = new Set<String>{CON_CRM.SYS_ADMIN_INTEGRATION_PROFILE, CON_CRM.SYS_ADMIN_MODULE_PROFILE, CON_CRM.SYS_ADMIN_PKG_SUPPORT_PROFILE, CON_CRM.MULESOFT_SYS_ADMIN_PROFILE, CON_CRM.SYSTEM_ADMIN_PROFILE, CON_CRM.IQVIA_SF_PLATFORM_PROFILE};
        String alertingEmail;   
        for(Agreement_Email_Alert__c agrEmailAlert : newEmailAlert){
            if(oldMap != Null){
                alertingEmail = oldMap.get(agrEmailAlert.Id).Alerting_Email__c;
            }
            else{
                alertingEmail = agrEmailAlert.Alerting_Email__c;
            }
            if(alertingEmail != userEmail && permissionNameByUser.size() == 0 && !adminProfiles.contains(profileName)){
                agrEmailAlert.addError(System.Label.CBEX_AgreementEmailAlertRecordUpdateErrorMessage);
            }
        }
    }
}