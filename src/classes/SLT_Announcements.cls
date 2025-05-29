/*
 * Version : 1.0
 * Description : This Apex class is selector layer for CSM Announcements
 */ 
public class SLT_Announcements {
    
    public List<CSM_QI_Announcement__c> selectAnnouncements1(String partnerType, String pillar, String expiredCondition) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c, PRM_Webinar__c FROM CSM_QI_Announcement__c WHERE CreatedDate = LAST_N_DAYS:180 AND Visible_to_PRM__c = true AND Id NOT IN (SELECT CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c) AND Id NOT IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c) AND Partner_Type__c INCLUDES (' + partnerType + ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition  + ' ORDER BY CreatedDate DESC');
    }

    public List<CSM_QI_Announcement__c> selectAnnouncements2(String partnerType, String pillar, String expiredCondition, String userAccountId) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c FROM CSM_QI_Announcement__c WHERE Visible_to_PRM__c = true AND Id NOT IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Product_Relationship__c) AND Id IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c WHERE account__c =\''+ userAccountId +'\') AND Partner_Type__c Includes (' + partnerType+ ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition + ' ORDER BY CreatedDate DESC');
    }
    
    public List<CSM_QI_Announcement__c> selectAnnouncements3(String partnerType, String pillar, String expiredCondition, String productsIds) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c FROM CSM_QI_Announcement__c WHERE CreatedDate = LAST_N_DAYS:180 AND Visible_to_PRM__c = true AND Id IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Product_Relationship__c WHERE product__c IN ('+ productsIds +') ) AND Id NOT IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c) AND Partner_Type__c Includes (' + partnerType+ ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition  + ' ORDER BY CreatedDate DESC');
    }
    
    public List<CSM_QI_Announcement__c> selectAnnouncements4(String partnerType, String pillar, String expiredCondition, String productsIds, String userAccountId) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c FROM CSM_QI_Announcement__c WHERE Visible_to_PRM__c = true AND Id IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Product_Relationship__c WHERE product__c IN ('+ productsIds +') ) AND Id IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c WHERE account__c =\''+ userAccountId +'\') AND Partner_Type__c INCLUDES (' + partnerType+ ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition + ' ORDER BY CreatedDate DESC');
    }
    
   public List<CSM_QI_Announcement__c> selectAnnouncements5(String partnerType, String pillar, String expiredCondition, String productsIds) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c FROM CSM_QI_Announcement__c WHERE Visible_to_PRM__c = true AND Id IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Product_Relationship__c WHERE product__c IN ('+ productsIds +') ) AND Id NOT IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c) AND Partner_Type__c Includes (' + partnerType+ ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition  + ' ORDER BY CreatedDate DESC');
    }
    
    public List<CSM_QI_Announcement__c> selectAnnouncements6(String partnerType, String pillar, String expiredCondition) {
        return Database.query('SELECT Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c,PRM_Modal_Style__c, PRM_Modal_Video_Id__c, PRM_Webinar__c FROM CSM_QI_Announcement__c WHERE Visible_to_PRM__c = true AND Id NOT IN (SELECT CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c) AND Id NOT IN (SELECT CSM_Announcement__c FROM CSM_QI_Announcement_Account_Relationship__c) AND Partner_Type__c INCLUDES (' + partnerType + ') AND Pillar__c INCLUDES (' + pillar + ') ' + expiredCondition  + ' ORDER BY CreatedDate DESC');
    }
    
    public List<CSM_QI_Announcement__c> selectAnnouncementById(String announcementId) {
        return Database.query('SELECT ID,Subject__c,Partner_Type__c,Pillar__c,Email_Sent__c,Expiry_Date__c,Email_Sent_for_CSM__c,Contact_User_Type__c,PRM_Active_Contract_Only__c FROM CSM_QI_Announcement__c WHERE ID =:announcementId ');
    }
    
    public List<CSM_QI_Announcement_Product_Relationship__c> selectAnnouncementByProduct(String announcementId) {
        return Database.query('SELECT Id,CSM_Announcement__c,Product__r.Name,Product__c FROM CSM_QI_Announcement_Product_Relationship__c WHERE CSM_Announcement__c =: announcementId');
    }
}