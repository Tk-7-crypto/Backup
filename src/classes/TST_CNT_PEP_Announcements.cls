@isTest
public class TST_CNT_PEP_Announcements { 
    @testSetup
    public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        partnerUser.EmployeeNumber = '07070703';
        adminUser.EmployeeNumber = '070707031';
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
            insert lstUsers;
        
        system.runAs(adminUser){
            List<Announcement__c> lstAnnouc = new List<Announcement__c>();
            Announcement__c a = TST_PEP_TestDataFactory.createAnnouncement('Announcement', 'Online', 'Description', 'Integrator Partner;CLM Agency', 'Consultant');
            a.Published_date__c = Date.today();
            a.Expiry_date__c = Date.today().addDays(4);
            lstAnnouc.add(a);
            insert lstAnnouc;
        }
    }
    @isTest 
    public static void testAnnouncement() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
       List<Announcement__c> lstAnnouc = new List<Announcement__c>();
        List<Announcement__c> lstAnnouc2 = new List<Announcement__c>();
        System.runAs(adminUser){
            Test.startTest();               
                lstAnnouc = CNT_PEP_Announcements.getAnnouncement();
                lstAnnouc2 = CNT_PEP_Announcements.getAnnouncementForHome();
            Test.stopTest();
         }       
        System.assert(lstAnnouc.size() > 0); 
        System.assert(lstAnnouc2.size() > 0); 
    }
}