@isTest(seeAllData = false)
public class TST_SLT_TPAContact {
    @isTest
    static void testSLT_TPAContact() {
        SLT_TPAContact.instance.getTPAContactByCodition('Type__c = \'test\' ');
    }
}