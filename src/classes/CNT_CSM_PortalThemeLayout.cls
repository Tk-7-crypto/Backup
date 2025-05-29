/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalThemeLayout component.
 */
public class CNT_CSM_PortalThemeLayout {
    @AuraEnabled
    public static List<Contact> getUserContact(){ 
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String>{'Portal_Case_Type__c','AccountId','Contact_User_Type__c','MikadoServiceLevel__c', 'Remove_KB_Access__c', 'Remove_Case_Creation__c', 'Remove_Dashboard_Access__c'});
        return contacts;
    }
    
    @AuraEnabled
    public static List<Major_Incident__c> getMajorIncidents(String accountId){ 
        List<Major_Incident__c> incidents = new List<Major_Incident__c>();
        Set<String> statusSet = new Set<String>();
        statusSet.add(CON_CSM.S_IN_PROGRESS);
        statusSet.add(CON_CSM.S_RESOLVED);
        incidents =[select Id, Major_Incident_Description__c, Major_Incident_Subject__c , Major_Incident_Customer_Communication__c, Status__c from Major_Incident__c where id in (select Major_Incident__c  from MI_AccountRelationship__c  where Accounts_Impacted__c =:accountId ) and  Status__c IN :statusSet];
        return incidents;
    }
    
    @AuraEnabled
    public static boolean checkTPAPermissionSetsAssigned(List<String> pmSetTPA){ 
        String userId = userInfo.getUserId();
        String profId = userInfo.getProfileId();
        boolean ret = false;
        if(userId != null && profId != null){
            List<Profile> proList = Database.query('select Id,Name from Profile where Id= :profId and Name in :pmSetTPA Limit 1');
            if(proList != null && proList.size() > 0 ){
                List<PermissionSetAssignment> pmSetList = Database.query('select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :userId and PermissionSet.Name =\'CSM_CSH_Community_Access\'');
                if(pmSetList != null && !pmSetList.isEmpty()){
                    ret = true;   
                }else{
                    ret = false;   
                }
            }
        }
        return ret;
    }

    @AuraEnabled
    public static User getCurrentUserInfo() {
        User currentUser;
        if(!UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS) || !UserInfo.getUserType().contains(CON_PEP.S_PEP_POWERPARTNER)) {
            Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id> {UserInfo.getUserId()}, new Set<String>{'Profile.Name', 'Name'});
            currentUser = userMap != null && userMap.size() > 0 && userMap.containsKey(userInfo.getUserId()) ? userMap.get(UserInfo.getUserId()) : null;
        }
        return currentUser;
    }
}