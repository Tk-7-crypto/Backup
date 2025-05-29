/**
 * This class is used to test SLT_Profile class
 */ 
@isTest
public class TST_SLT_Profile {
    
    static testMethod void testSelectById() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Sales User' LIMIT 1];
        Set<Id> profileIdSet = new Set<Id>();
        profileIdSet.add(profile.Id);
        Test.startTest();
        List<Profile> profileList = new SLT_Profile().selectById(profileIdSet);
        System.assertEquals('Sales User',profileList[0].Name);
        Test.stopTest();
    }    
	
    static testMethod void testSelectProfileByName() {

        Test.startTest();
        List<Profile> profileList = new SLT_Profile().selectProfileByName(New Set<String>{'Sales User'}, new Set<String>{'Id','Name'});
        System.assertEquals('Sales User',profileList[0].Name);
        Test.stopTest();
    } 
    
    static testMethod void testGetProfileByName() {

        Test.startTest();
            Profile profileData = new SLT_Profile().getProfileByName(New Set<String>{CON_CPQ.SALES_USER}, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
            System.assertEquals(profileData != null, true, 'result is not empty');
        Test.stopTest();
    }
    
    static testMethod void testGetAdminProfiles() {

        Test.startTest();
            List<Profile> profileList = new SLT_Profile().getAdminProfiles(new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
            System.assertEquals(profileList.size() > 0, true, 'Profile List is not empty');
        Test.stopTest();
    }
}