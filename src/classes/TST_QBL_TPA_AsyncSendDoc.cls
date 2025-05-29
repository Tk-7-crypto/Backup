@isTest(seeAllData = false)
public class TST_QBL_TPA_AsyncSendDoc {
    public static testMethod void testQBL_TPA_AsyncSendDoc() {
        QBL_TPA_AsyncSendDoc queuableObject = new QBL_TPA_AsyncSendDoc();
        
        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
}