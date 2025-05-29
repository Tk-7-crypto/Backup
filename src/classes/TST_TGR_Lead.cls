/**
 * This test class is used to test Lead Trigger.
 * version : 1.0
 */
@isTest
private class TST_TGR_Lead {
    
    /**
     * This test method used for insert Lead record
     */ 
    static testMethod void testInsertLead() {
        test.startTest();
            Lead newLead = UTL_TestData.createLead();
            insert newLead;
        test.stopTest();
        Lead existingLead = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Lead LIMIT 1];
        //System.assertEquals(true, existingLead.Invalid_Email_Address__c);
        System.assertEquals(null, existingLead.Consented_to_Marketing_Emails__c);
    }
}