@isTest
public class TST_CNT_CDA_CDALookupTool { 
    @isTest
    public static void testsearchCDARequests(){
        CNT_CDA_CDALookupTool obj = new CNT_CDA_CDALookupTool();
        obj.searchCDARequests();
        String sorting = obj.sortOrder;
        obj.getcdaRequests();
        Integer pNo = obj.currentPageNo;
        obj.pageSize = 10;
        obj.sortData();
        Integer totalRec = obj.totalNoOfRec;
        obj.settableSize();
    }

}