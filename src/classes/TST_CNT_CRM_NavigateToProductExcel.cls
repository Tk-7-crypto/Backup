@isTest
public class TST_CNT_CRM_NavigateToProductExcel {
    
    @isTest
    public static void testNavigateToProductExcel() {
        ApexPages.standardController controller = new ApexPages.standardController(new Opportunity());
        CNT_CRM_NavigateToProductExcel obj = new CNT_CRM_NavigateToProductExcel(controller);
        String expectedxmlheader = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        String expectedendfile = '</Workbook>';
        Test.startTest();
        obj.getCurrentTime();
        System.assertEquals(expectedxmlheader, obj.xmlheader);
        System.assertEquals(expectedendfile, obj.endfile);
        Test.stopTest();
    }
}