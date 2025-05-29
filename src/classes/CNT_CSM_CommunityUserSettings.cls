public without sharing class CNT_CSM_CommunityUserSettings {
    @AuraEnabled
    public static Contact getContactEmailOptOut(){
        User user = new SLT_User().selectUserByUserId(new Set<Id>{UserInfo.getUserId()});
        if(user != null){
            List<Contact> conList = new SLT_Contact().selectByContactIdList(new Set<Id>{user.ContactId}, new Set<String>{'Id','EmailOptOut__c'});
            if(conList != null && !conList.isEmpty()){
                return conList[0];
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static Contact saveEmailOptOut(String contactId, boolean emailOptOut){
        //Contact conList = new SLT_Contact().selectByContactIdList(new Set<Id>{contactId}, new Set<String>{'Id','EmailOptOut__c'});
        Contact con = [Select Id,EmailOptOut__c FROM Contact WHERE Id =:contactId];
        if(con != null){
            con.EmailOptOut__c = emailOptOut;
            try{
                update con; 
            }catch(System.DmlException e){
                System.debug('Exception :' + e.getMessage());
            }
        }
        return con;
    }
}
