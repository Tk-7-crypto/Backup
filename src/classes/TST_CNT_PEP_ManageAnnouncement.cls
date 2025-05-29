@isTest
public class TST_CNT_PEP_ManageAnnouncement {
    @testSetup
    public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
            insert lstUsers;
        
        system.runAs(adminUser){
            List<Announcement__c> lstAnnouc = new List<Announcement__c>();
            lstAnnouc.add(TST_PEP_TestDataFactory.createAnnouncement('Announcement', 'Draft', 'Description', 'Integrator Partner;CLM Agency', 'Manager'));
            lstAnnouc.add(TST_PEP_TestDataFactory.createAnnouncement('Announcement2', 'Draft', 'Description2', 'Integrator Partner; Data Partner', null));
            
            insert lstAnnouc;
            
            List<Account> acc = new List<Account>();
            for(Integer i=0; i<6; i++) {
                acc.add(TST_PEP_TestDataFactory.createAccount('AccountTest' + i));
            }
            insert acc;
            
            String ann = [select id from Announcement__c LIMIT 1].id;
            
            List<Targeted_Account_Announcement__c> taLst = new List<Targeted_Account_Announcement__c>();
            String tann = [select id from Account LIMIT 1].id;
            for(Integer i=0; i<6; i++) {
                taLst.add(TST_PEP_TestDataFactory.createTargetedAccountAnnouncement(ann, tann));
            }
            insert taLst;
            
            List<Targeted_User_Announcement__c> tuLst = new List<Targeted_User_Announcement__c>();
            String tuann = [select id from User LIMIT 1].id;
            tuLst.add(TST_PEP_TestDataFactory.createTargetedUserAnnouncement(ann, tuann));
            insert tuLst;
            
            List<Product2> prod = new List<Product2>();
            for(Integer i=0; i<6; i++) {
                prod.add(TST_PEP_TestDataFactory.createProduct('Producttest' + i));
            }
            insert prod;
        }
    }
    
    @isTest
    public static void testCreateAnnouncement() {
        Announcement__c anc = [SELECT id, Status__c FROM Announcement__c LIMIT 1];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Account> accList = [Select id from Account];
        List<Product2> prodLst = [Select id from Product2];
        id announcementId = null;
        Date now = Date.today();
        Date expDate = now.addDays(4);
        System.runAs(adminUser){
            Test.startTest();               
                announcementId = CNT_PEP_ManageAnnouncement.createAnnouncement('Subject', 'Draft', 'Desc', 'Integrator Partner', 'Consultant', prodLst[0].id,expDate, accList, anc.id);
            Test.stopTest();
         }       
        System.assert(announcementId != null); 
        System.assertEquals(announcementId,anc.id);
    }
    
    @isTest
    public static void testGetAccounts() {
        Announcement__c anc = [SELECT id, Status__c FROM Announcement__c LIMIT 1];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Targeted_Account_Announcement__c> acLst = new List<Targeted_Account_Announcement__c>();
        System.runAs(adminUser){
            Test.startTest();               
                acLst = CNT_PEP_ManageAnnouncement.getAccounts(anc.id);
            Test.stopTest();
         }       
        System.assert(acLst != null); 
    }
    
    @isTest
    public static void testPublishAnnouncements() {
        List<Announcement__c> anc = [SELECT id FROM Announcement__c where Subject__c = 'Announcement2'];
        
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Targeted_User_Announcement__c> tuLst = new List<Targeted_User_Announcement__c>();
        System.runAs(adminUser){
            Test.startTest();
                tuLst = CNT_PEP_ManageAnnouncement.publishAnnouncements(anc[0].Id);
            Test.stopTest();
         }       
        System.assert(tuLst != null);
    }

    @isTest
    public static void testPublishAnnouncementsfiltered() {
        List<Announcement__c> anc = [SELECT id FROM Announcement__c where Subject__c = 'Announcement'];
        
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<Targeted_User_Announcement__c> tuLst = new List<Targeted_User_Announcement__c>();
        System.runAs(adminUser){
            Test.startTest();
                tuLst = CNT_PEP_ManageAnnouncement.publishAnnouncements(anc[0].Id);
            Test.stopTest();
         }       
        System.assert(tuLst != null);
    }
    
    @isTest
    public static void testUnPublishAnnouncements() {
        Announcement__c anc = [SELECT id, Status__c FROM Announcement__c LIMIT 1];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        Boolean val = false;
        System.runAs(adminUser){
            Test.startTest();               
                val = CNT_PEP_ManageAnnouncement.unPublishAnnouncements(anc.id);
            Test.stopTest();
         }       
        System.assertEquals(val, true);
    }
    
    @isTest
    public static void testCreateAnnoucementShare() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<User> adminUserList = new List<User>();
        adminUserList.add(adminUser);
        Announcement__c anc = [SELECT id, Status__c FROM Announcement__c LIMIT 1];
        List<Announcement__Share> announcementShareList = new List<Announcement__Share>();
        System.runAs(adminUser){
            Test.startTest();               
                announcementShareList = CNT_PEP_ManageAnnouncement.createAnnoucementShare(adminUserList, anc.Id);
            Test.stopTest();
         }       
        System.assert(announcementShareList != null);
    }
    
    @isTest
    public static void testCreateTargetedUserAnnoucement() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<User> adminUserList = new List<User>();
        adminUserList.add(adminUser);
        Announcement__c anc = [SELECT id, Status__c FROM Announcement__c LIMIT 1];
        List<Targeted_User_Announcement__c> targetedUserList = new List<Targeted_User_Announcement__c>();
        System.runAs(adminUser){
            Test.startTest();               
                targetedUserList = CNT_PEP_ManageAnnouncement.createTargetedUserAnnoucement(adminUserList, anc.Id);
            Test.stopTest();
         }       
        System.assert(targetedUserList != null);
    }
}