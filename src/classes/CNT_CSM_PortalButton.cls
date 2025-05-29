/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalButton component.
 */
public class CNT_CSM_PortalButton { 
    @AuraEnabled
    public static List<Contact> getUserContact(){ 
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String>{'Portal_Case_Type__c'});
        return contacts;
    }
}