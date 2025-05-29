@isTest
public class TST_QUE_CPQ_TimeDelayForSchedule {
    
    @isTest
    static void testTimeDelayForSchedule() {
        Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleListByOliId = new Map<Id, List<OpportunityLineItemSchedule>>();
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        
        Test.startTest();
            System.enqueueJob(new QUE_CPQ_TimeDelayForSchedule(lineItemScheduleListByOliId,proposal.id));
        Test.stopTest();
        
    }
}