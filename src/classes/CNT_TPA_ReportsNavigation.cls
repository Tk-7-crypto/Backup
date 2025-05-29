public class CNT_TPA_ReportsNavigation {
    public String baseURL{
        get{
            return (baseURL == null ? TPA_Settings__c.getOrgDefaults().Base_Url__c : baseURL);
        }
    }
    // private List<TPA_AMA_Settings__c> amaSetting;
    // public String BillingSAPReportForYear{get;set;}
    // public boolean isSapBillingReportAccessible {
    //     get {
    //         List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'AMA_Admin'];
    //         List<Profile> currentUserProfileList = [Select Name from Profile where Id =: UserInfo.getProfileId() and Name = 'System Administrator'];
    //         if((currentUserPermissionSetList != null && currentUserPermissionSetList.size() > 0) || (currentUserProfileList != null && currentUserProfileList.size() > 0)) {
    //             return true;
    //         }
    //         return false;
    //     }
    //     private set;
    // }
    
    public CNT_TPA_ReportsNavigation() {
        // if(amaSetting == null) {
        //     amaSetting = TPA_AMA_Settings__c.getAll().values();
        //     if(!amaSetting.isEmpty() && amaSetting.get(0).Billing_SAP_Report_For_Year__c != null && amaSetting.get(0).Billing_SAP_Report_For_Year__c != '')
        //         BillingSAPReportForYear = amaSetting.get(0).Billing_SAP_Report_For_Year__c ; 
        // }        
    }
    
    // public void generateBillingReport(){
    //     Database.executeBatch(new BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr(),200);        
    // }
    
}