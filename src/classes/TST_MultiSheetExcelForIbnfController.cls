@isTest
public class TST_MultiSheetExcelForIbnfController {

    @isTest public static void testMultiSheetExcelForIbnfController() {
        MultiSheetExcelForIbnfController msc = new MultiSheetExcelForIbnfController();
        String expectedxmlheader = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        String expectedendfile = '</Workbook>';
        List<OpportunityLineItem> expectedopptyli;
   		BNF2__c expectedBNF; 
        Boolean expectedisnewbnf;
        Test.startTest();
        System.assertEquals(expectedxmlheader, msc.xmlheader);
        System.assertEquals(expectedendfile, msc.endfile);
        System.assertEquals(expectedopptyli, msc.opptyli);
        System.assertEquals(expectedBNF, msc.BNF);
        System.assertEquals(expectedisnewbnf, msc.isnewbnf);
        Test.stopTest();
    }
    
    @isTest public static void testGetBillingscheduleitems() {
        MultiSheetExcelForIbnfController msc = new MultiSheetExcelForIbnfController();
        Map<String,List<Billing_Schedule_Item__c>> expectedmap = new Map<String,List<Billing_Schedule_Item__c>>();
        expectedmap = msc.getBillingscheduleitems();
        Test.startTest();
        System.assertEquals(expectedmap, msc.billingscheduleitems);
        Test.stopTest();        
    }
    
    @isTest public static void testGetRevenuescheduleitems() {
        MultiSheetExcelForIbnfController msc = new MultiSheetExcelForIbnfController();
        Map<String,List<OpportunityLineItemSchedule>> expectedmap = new Map<String,List<OpportunityLineItemSchedule>>();
        expectedmap = msc.getRevenuescheduleitems();
        Test.startTest();
        System.assertEquals(expectedmap, msc.revenuescheduleitems);
        Test.stopTest();        
    }
    
    @isTest public static void testSetRevenueschedulritems() {
        MultiSheetExcelForIbnfController msc = new MultiSheetExcelForIbnfController();
        Test.startTest();
        msc.setRevenuescheduleitemsstring('Test');
        Test.stopTest();
    }
    
    @isTest public static void testSetBillingschedulritems() {
        MultiSheetExcelForIbnfController msc = new MultiSheetExcelForIbnfController();
        Test.startTest();
        msc.setBillingscheduleitemsstring('Test');
        Test.stopTest();
    }
}