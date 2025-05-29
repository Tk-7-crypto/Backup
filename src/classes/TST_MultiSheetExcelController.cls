@isTest
public class TST_MultiSheetExcelController {

    @isTest
    public static void testMultiSheetExcelController() {
        MultiSheetExcelController msc = new MultiSheetExcelController();
        String expectedxmlheader = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        String expectedendfile = '</Workbook>';
        List<OpportunityLineItem> expectedopptyli;
   		BNF2__c expectedBNF; 
        Test.startTest();
        System.assertEquals(expectedxmlheader, msc.xmlheader);
        System.assertEquals(expectedendfile, msc.endfile);
        System.assertEquals(expectedopptyli, msc.opptyli);
        System.assertEquals(expectedBNF, msc.BNF);
        Test.stopTest();
    }
    
    @isTest 
    public static void testSetRevenuescheduleItems() {
        MultiSheetExcelController msc = new MultiSheetExcelController();
        Test.startTest();
            msc.setRevenuescheduleitemsstring('Test');
        Test.stopTest();
    }
    
    @isTest 
    public static void testGetRevenuescheduleItems() {
        MultiSheetExcelController msc = new MultiSheetExcelController();
        Map<String,List<OpportunityLineItemSchedule>> expectedmap = new Map<String,List<OpportunityLineItemSchedule>>();
        expectedmap = msc.getRevenuescheduleitems();
        Test.startTest();
            System.assertEquals(expectedmap, msc.revenuescheduleitems);
        Test.stopTest();        
    }
}