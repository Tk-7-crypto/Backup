@isTest
public class TST_MultiSheetExcelForMibnfController {

    @isTest public static void testMultiSheetExcelForMibnfController() {
        MultiSheetExcelForMibnfController msc = new MultiSheetExcelForMibnfController();
        String expectedxmlheader = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        String expectedendfile = '</Workbook>';
        List<OpportunityLineItem> expectedopptyli;
   		MIBNF2__c expectedMIBNF; 
        MIBNF_Component__c expectedMIBNF_Comp;
        Boolean expectedisnewbnf;
        Test.startTest();
        System.assertEquals(expectedxmlheader, msc.xmlheader);
        System.assertEquals(expectedendfile, msc.endfile);
        System.assertEquals(expectedopptyli, msc.opptyli);
        System.assertEquals(expectedMIBNF, msc.MIBNF);
        System.assertEquals(expectedisnewbnf, msc.isnewbnf);
        System.assertEquals(expectedMIBNF_Comp, msc.MIBNF_Comp);
        Test.stopTest();
    }
    
    @isTest public static void testGetBillingscheduleitems() {
        MultiSheetExcelForMibnfController msc = new MultiSheetExcelForMibnfController();
        Map<String,List<Billing_Schedule_Item__c>> expectedmap = new Map<String,List<Billing_Schedule_Item__c>>();
        expectedmap = msc.getBillingscheduleitems();
        Test.startTest();
        System.assertEquals(expectedmap, msc.billingscheduleitems);
        Test.stopTest();        
    }
    
    @isTest public static void testGetRevenuescheduleitems() {
        MultiSheetExcelForMibnfController msc = new MultiSheetExcelForMibnfController();
        Map<String,List<OpportunityLineItemSchedule>> expectedmap = new Map<String,List<OpportunityLineItemSchedule>>();
        expectedmap = msc.getRevenuescheduleitems();
        Test.startTest();
        System.assertEquals(expectedmap, msc.revenuescheduleitems);
        Test.stopTest();        
    }
    
    @isTest public static void testSetRevenueschedulritems() {
        MultiSheetExcelForMibnfController msc = new MultiSheetExcelForMibnfController();
        Test.startTest();
        msc.setRevenuescheduleitemsstring('Test');
        Test.stopTest();
    }
    
    @isTest public static void testSetBillingschedulritems() {
        MultiSheetExcelForMibnfController msc = new MultiSheetExcelForMibnfController();
        Test.startTest();
        msc.setBillingscheduleitemsstring('Test');
        Test.stopTest();
    }
}