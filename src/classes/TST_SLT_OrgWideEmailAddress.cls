@isTest
public class TST_SLT_OrgWideEmailAddress {
    
    @isTest
    static void testSelectOrgWideEmailAddressById() {
        
        OrgWideEmailAddress emailAdress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :CON_CPQ.CPQ_Foundation_Tool_Display_Name LIMIT 1];
        Set<Id> idSet = new Set<Id>{emailAdress.Id};
            
        Test.startTest();
            List<OrgWideEmailAddress> OrgWideEmailAddressList = new SLT_OrgWideEmailAddress().selectById(idSet);
        Test.stopTest();
        
        system.assertEquals(1, OrgWideEmailAddressList.size(), 'Should return one OrgWideEmailAddress');
    }
    
    @isTest
    static void testSelectOrgWideEmailAddressByEmailAdress() {
        OrgWideEmailAddress emailAdress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = :CON_CPQ.CPQ_Foundation_Tool_Display_Name LIMIT 1];
        
        Test.startTest();
            List<OrgWideEmailAddress> OrgWideEmailAddressList = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(
                emailAdress.Address, new Set<String>{CON_CPQ.Id});
        Test.stopTest();
        
        system.assertEquals(1, OrgWideEmailAddressList.size(), 'Should return one OrgWideEmailAddress');
    }
    
    @isTest
    static void testSelectOrgWideEmailAddressByName() {
        
        OrgWideEmailAddress emailAdress = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :CON_CPQ.CPQ_Foundation_Tool_Display_Name LIMIT 1];
        
        Test.startTest();
            List<OrgWideEmailAddress> OrgWideEmailAddressList = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByName(
                emailAdress.DisplayName, new Set<String>{CON_CPQ.Id});
        Test.stopTest();
        
        system.assertEquals(1, OrgWideEmailAddressList.size(), 'Should return one OrgWideEmailAddress');
    }
}