public with sharing class CNT_CPQ_AdminScreenController {
    @AuraEnabled
    public static List<WRP_AdminScreenClass> getPermissionsetRecords() {
        List<WRP_AdminScreenClass> wrapAdminscreenList = new List<WRP_AdminScreenClass>();
        Map<String, List<CPQ_Admin_Features_Setting__c>> adminScreenSettings = new Map<String, List<CPQ_Admin_Features_Setting__c>>();
        try {
            String profileName = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserId()][0].Profile.Name;
            Boolean isAdminProfile = (profileName == CON_CPQ.SYSTEM_ADMIN_PROFILE ? true : false);
            for (CPQ_Admin_Features_Setting__c adminFeature : [SELECT Permission_set_Name__c, CPQ_Feature_Name__c, DataLoad_Path__c FROM CPQ_Admin_Features_Setting__c]) {
                if (isAdminProfile) {
                    wrapAdminscreenList.add(new WRP_AdminScreenClass(adminFeature.CPQ_Feature_Name__c, adminFeature.DataLoad_Path__c));
                } else if (!adminScreenSettings.containsKey(adminFeature.Permission_set_Name__c)) {
                    adminScreenSettings.put(adminFeature.Permission_set_Name__c, new List<CPQ_Admin_Features_Setting__c>{adminFeature});
                } else {
                    adminScreenSettings.get(adminFeature.Permission_set_Name__c).add(adminFeature);
                }
            }
            if (!isAdminProfile) {
                for (PermissionSetAssignment pSet :[SELECT PermissionSet.Name, Assignee.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()]) {
                    if (adminScreenSettings.containsKey(pSet.PermissionSet.Name) && adminScreenSettings.get(pSet.PermissionSet.Name).size() > 0) {
                        for (CPQ_Admin_Features_Setting__c adm : adminScreenSettings.get(pSet.PermissionSet.Name)) {
                            wrapAdminscreenList.add(new WRP_AdminScreenClass(adm.CPQ_Feature_Name__c, adm.DataLoad_Path__c));
                        }
                    }
                }
            }
            return wrapAdminscreenList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class WRP_AdminScreenClass {
        @AuraEnabled
        public String cpqFeature {get;set;}
        @AuraEnabled
        public String lwcComponentData {get;set;}
       
        public WRP_AdminScreenClass(String cpqFeature, String lwcComponentData) {
            this.cpqFeature = cpqFeature;
            this.lwcComponentData = lwcComponentData;
        }
    }
}