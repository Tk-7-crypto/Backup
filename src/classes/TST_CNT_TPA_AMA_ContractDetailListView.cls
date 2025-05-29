/*
*@Author  : Supriya Johhari
*@Purpose : 1. Test class for Controller  AMAImportFromContractDetailController page
               to check the process of csv data upload for AMA.
*/
@isTest(seeAllData=false)
public class TST_CNT_TPA_AMA_ContractDetailListView {

    private static CNT_TPA_AMA_ContractDetailListView amaContractDetailListViewControllerObj ;
    private static String viewTestName ;
    private static String listTestName ;
    private static String getName = '';
    private static String getId = '';

    /**
    * Setup test data required to run tests in a data independent fashion
    */
    static void setupTestData() {
        viewTestName = 'AMA Contract Detail';
        listTestName = 'AMA Contract Detail';
    }

    public static testMethod void test_positiveCases(){


        setupTestData();
        test.startTest();
        amaContractDetailListViewControllerObj = new CNT_TPA_AMA_ContractDetailListView();

        amaContractDetailListViewControllerObj.viewName = viewTestName;
        getName = amaContractDetailListViewControllerObj.viewName;
        System.assertEquals(viewTestName, getName);

        amaContractDetailListViewControllerObj.listName = listTestName;
        getName = amaContractDetailListViewControllerObj.listName;
        System.assertEquals(listTestName, getName);

        getId = amaContractDetailListViewControllerObj.listId;
        System.Assert(getId != null);

        test.stopTest();

    }

     public static testMethod void test_negativeCases(){


        setupTestData();
        test.startTest();
        amaContractDetailListViewControllerObj = new CNT_TPA_AMA_ContractDetailListView();

        //amaContractDetailListViewControllerObj.viewName = viewTestName;
        getName = amaContractDetailListViewControllerObj.viewName;
        System.assertEquals(viewTestName, getName);

        amaContractDetailListViewControllerObj.listName = listTestName;
        getName = amaContractDetailListViewControllerObj.listName;
        System.assertEquals(listTestName, getName);

        getId = amaContractDetailListViewControllerObj.listId;
        System.Assert(getId != null);

         amaContractDetailListViewControllerObj.getTPAQuery();
        amaContractDetailListViewControllerObj.getamaContractDetails();
        amaContractDetailListViewControllerObj.setView();
          amaContractDetailListViewControllerObj.sortData();
          amaContractDetailListViewControllerObj.settableSize();

        test.stopTest();

    }




}