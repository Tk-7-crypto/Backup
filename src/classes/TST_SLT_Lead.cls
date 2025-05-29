/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Lead
 */
@isTest
private class TST_SLT_Lead {
    
    /**
     * This method used to get lead by lead Id.
     */    
    @IsTest
    static void testSelectById() {
        Lead lead = new Lead(FirstName = 'TestLead', Email = 'test@gmail.com', Country = 'USA', LastName = 'test', Company = 'test', Status = 'Not Started');
        insert lead;
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'id','Phone','Email'};
        Map<Id, Lead> idToLeadMap = new SLT_Lead().selectByLeadId(new Set<Id> {lead.id}, fieldSet );
        Test.stopTest();
        Integer expected = 1;
        Integer actual = idToLeadMap.size();
        System.assertEquals(expected, actual);
    }
    
}