@isTest
public class TST_RevisedRevenueScheduleController {
    
    public static ApexPages.StandardController controller {get;set;}
    
    /*
* This method is used to setup test data
*/
    @testSetup
    static void setupData(){
        Account testAcccount = UTL_TestData.createAccount();
        insert testAcccount;
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAcccount.Id); 
        insert testOpportunity;
        Product2 testProduct = UTL_TestData.createProduct();
        testProduct.Item_Category_Group__c = 'ZLIC';
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.Id);
        insert testPricebookEntry;
        OpportunityLineItem testOpportunityLineItem = UTL_TestData.createOpportunityLineItem(testOpportunity.Id,testPricebookEntry.Id);
        testOpportunityLineItem.Revised_Revenue_Schedule__c = '20160222:100|20180628:100';
        testOpportunityLineItem.Project_End_Date__c = Date.newInstance(2019, 02, 20);
        testOpportunityLineItem.Project_Start_Date__c = Date.newInstance(2019, 02, 20);
        insert testOpportunityLineItem;
        OpportunityLineItemSchedule testOpportunityLineItemSchedule = UTL_TestData.createOpportunityLineItemSchedule(testOpportunityLineItem.Id);
        insert testOpportunityLineItemSchedule;
    }
    /*
* This method is used to setup a controller 
*/
    static RevisedRevenueScheduleController getController(){
        Opportunity testOpportunity = [select Id from Opportunity where name ='TestOpportunity'];
        OpportunityLineItem testOpportunityLineItem = [select Id, Revised_Revenue_Schedule__c, PricebookEntry.Product2.Item_Category_Group__c, PricebookEntry.Product2.material_type__c, Product_Start_Date__c,Product_End_Date__c,Project_Start_Date__c,Project_End_Date__c from OpportunityLineItem where OpportunityId =: testOpportunity.Id];
        system.debug(testOpportunityLineItem.Revised_Revenue_Schedule__c);
        controller = new ApexPages.StandardController(testOpportunityLineItem);  
        RevisedRevenueScheduleController revisedrevenueschedulecontroller = new RevisedRevenueScheduleController(controller);
        PageReference pageRef = Page.revised_revenue_schedule;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(testOpportunityLineItem.Id));
        pageRef.getParameters().put('startdate','12/03/18');
        pageRef.getParameters().put('enddate','02/07/18');
        pageRef.getParameters().put('OriginalRevSchedules','false');
        
        return revisedrevenueschedulecontroller;
    }
    
    @isTest
    static void constructorTestWhenItemGroupIsZLIC(){
        Test.startTest();
        getController();
        Test.stopTest();
    }
    
    @isTest
    static void constructorTestWhenMaterialTypeIsZREP(){
        Product2 testProduct = [Select id, Material_Type__c from Product2 where name = 'TestProduct'];
        testProduct.Item_Category_Group__c = '';
        testProduct.Material_Type__c = 'ZREP';
        update testProduct;
        Test.startTest();
        getController();
        Test.stopTest();
    }
    
    @isTest
    static void saveMethodTest(){
        Test.startTest();
        getController().Save();
        Test.stopTest();
    }
    
    @isTest
    static void saveMoreMethodTest(){
        Test.startTest();
        getController().SaveMore();
        Test.stopTest();
    }
    
    @isTest
    static void constructorTestWhenRevisedRevenueScheduleIsBlank(){
        Opportunity testOpportunity = [select Id from Opportunity where name ='TestOpportunity'];
        OpportunityLineItem testOpportunityLineItem = [select Id, Revised_Revenue_Schedule__c, PricebookEntry.Product2.Item_Category_Group__c, PricebookEntry.Product2.material_type__c, Product_Start_Date__c,Product_End_Date__c,Project_Start_Date__c,Project_End_Date__c from OpportunityLineItem where OpportunityId =: testOpportunity.Id];
        system.debug(testOpportunityLineItem.Revised_Revenue_Schedule__c);
        testOpportunityLineItem.Revised_Revenue_Schedule__c ='';
        update testOpportunityLineItem;
        Test.startTest();
        getController();
        Test.stopTest();
    }
    
    @isTest
    static void testSorting(){
        Opportunity testOpportunity = [select Id from Opportunity where name ='TestOpportunity'];
        OpportunityLineItem testOpportunityLineItem = [select Id, Revised_Revenue_Schedule__c, PricebookEntry.Product2.Item_Category_Group__c, PricebookEntry.Product2.material_type__c, Product_Start_Date__c,Product_End_Date__c,Project_Start_Date__c,Project_End_Date__c from OpportunityLineItem where OpportunityId =: testOpportunity.Id];
        OpportunityLineItemSchedule testOpportunityLineItemSchedule = UTL_TestData.createOpportunityLineItemSchedule(testOpportunityLineItem.Id);
        insert testOpportunityLineItemSchedule;
        controller = new ApexPages.StandardController(testOpportunityLineItem);  
        RevisedRevenueScheduleController revisedrevenueschedulecontroller = new RevisedRevenueScheduleController(controller);
        Test.startTest();
        revisedrevenueschedulecontroller.fieldName = 'Revenue';
        revisedrevenueschedulecontroller.descending = true;
        revisedrevenueschedulecontroller.sorting();
        revisedrevenueschedulecontroller.fieldName = 'Revenue';
        revisedrevenueschedulecontroller.descending = false;
        revisedrevenueschedulecontroller.sorting();
        revisedrevenueschedulecontroller.fieldName = 'ScheduleDate';
        revisedrevenueschedulecontroller.ascending = true;
        revisedrevenueschedulecontroller.sorting();
        revisedrevenueschedulecontroller.fieldName = 'ScheduleDate';
        revisedrevenueschedulecontroller.ascending = false;
        revisedrevenueschedulecontroller.sorting();
        Test.stopTest();
    }
}