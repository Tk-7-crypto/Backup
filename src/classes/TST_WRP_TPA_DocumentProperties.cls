@isTest(SeeAllData=false)
public class TST_WRP_TPA_DocumentProperties {

    @isTest
    public static void testWrapper(){
        WRP_TPA_DocumentProperties obj = new WRP_TPA_DocumentProperties();
        obj.documentId = '';
        obj.name = '';
        obj.display = '';
        obj.order = '';
        obj.pages = '';
    }
}