/*
*@Author  : Sunny Bansal 
*@Purpose : Test class for Controller UTL_TPA_AMA_RowIterator
*/
@isTest(seeAllData=false)
public class TST_UTL_TPA_AMA_RowIterator { 
    
    private static String clientListCSV1;
    private static String clientListCSV2;
    private static boolean fileIteratedSuccessfully = false;
    
    /**
    * Setup test data required to run tests in a data independent fashion
    */
    static void setupTestData() {
        clientListCSV1 = 'CLIENT Name,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEES REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS AND CONDITIONS'+'\r\n'+'abc,rtf,,,,,,,,'+'\r\n'+'"Abbie,tup","tyf,LLc","rty,abc",tyu,11/30/1992,tyu,Y,False,loc,uop'+'\r\n'+',,,LEGEND,,,,,,'+'\r\n'+',,,,,,,,,'+'\r\n'+',,,DATABASE LICENSEES,,,,,,';
        clientListCSV2 = 'CLIENT Name,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEES REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS AND CONDITIONS'+'\n'+'abc,rtf,,,,,,,,'+'\n'+'"Abbie,tup","tyf,LLc","rty,abc",tyu,11/30/1992,tyu,Y,False,loc,uop';
    }
    
    /**
     * Method Name: testcases_clientListUploaded_WithRowDelimiter
     * Desc: To iterate a csv file that contains primary row delimiter i.e. '\r\n'
    */
    public static testMethod void testcases_clientListUploaded_WithRowDelimiter() {
        setupTestData();
        Test.startTest();
        UTL_TPA_AMA_RowIterator lineIterator = New UTL_TPA_AMA_RowIterator(clientListCSV1,'\r\n','\n');
        while(lineIterator.hasNext()) {
            String nextRow = lineIterator.next();
            fileIteratedSuccessfully = true;
            if(nextRow.equalsIgnoreCase('File Ended')) {
                break;
            }
        }
        lineIterator.Iterator();
        System.assertEquals(true,fileIteratedSuccessfully);
        Test.stopTest();
    }
    
    /**
     * Method Name: testcases_clientListUploaded_WithAlternateRowDelimiter
     * Desc: To iterate a csv file that contains alternate row delimiter i.e. '\n'
    */
    public static testMethod void testcases_clientListUploaded_WithAlternateRowDelimiter() {
        setupTestData();
        Test.startTest();
        UTL_TPA_AMA_RowIterator lineIterator = New UTL_TPA_AMA_RowIterator(clientListCSV2,'\r\n','\n');
        while(lineIterator.hasNext()) {
            String nextRow = lineIterator.next();
            fileIteratedSuccessfully = true;
            if(nextRow.equalsIgnoreCase('File Ended')) {
                break;
            }
        }
        System.assertEquals(true,fileIteratedSuccessfully);
        Test.stopTest();
    }
}