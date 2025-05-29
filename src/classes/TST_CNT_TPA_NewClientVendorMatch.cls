/*
*@Author  : Supriya Johhari
*@Purpose : 1. Test class for Controller  CNT_TPA_NewClientVendorMatch page 
               to check the process of New clients and vendors identified by the system.     
*/
@isTest(seeAllData=false)
public class TST_CNT_TPA_NewClientVendorMatch {
  
    private static TPA_AMA_Client_Vendor_Search_Map__c searchMapObj;
    private static CNT_TPA_NewClientVendorMatch amaControllerObj;
    private static string serializeMapRecord;
    private static Boolean isBatchProcessing;

    public static void createTestData() {
        //Account acctObj  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test AMA Account',123);
        Address__c acctObj  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test AMA Account',123);
        searchMapObj = new TPA_AMA_Client_Vendor_Search_Map__c(AMA_Account_Search_Text__c ='Test AMA account', TPA_Account_Address__c = acctObj.id);
        serializeMapRecord = JSON.serialize(searchMapObj);
    }   
    
    public static void createTestData2() {
        //Account acctObj  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test AMA Account',123);
        Address__c acctObj  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test AMA Account',123);
        //acctObj.BillingStreet = '';
        acctObj.Street__c = '';
        acctObj.Is_TPA_Account__c = true;
        update acctObj;
        searchMapObj = new TPA_AMA_Client_Vendor_Search_Map__c(AMA_Account_Search_Text__c ='Test AMA account', TPA_Account_Address__c = acctObj.id);
        serializeMapRecord = JSON.serialize(searchMapObj);
    }
     
    /**
    * Setup test data required to run tests in a data independent fashion
    */    
    @testSetup static void setup() {
    
        List<TPA_AMA_Client_Vendor_Match__c> clientVendorMatchList = new List<TPA_AMA_Client_Vendor_Match__c>();
        Address__c acct1 = UTL_TPA_SetupTestData.getAddress();
        acct1.Is_TPA_Account__c = false;
        insert acct1;
        
        //Account acct2  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('xyz',123);
        Address__C acct2  = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('xyz',123);
        //acct2.BillingStreet = '';
        acct2.Street__c = '';
        acct2.Is_TPA_Account__c = true;
        update acct2;
        
        TPA_AMA_Client_Vendor_Match__c ob1 = new TPA_AMA_Client_Vendor_Match__c(Client_Name__c ='20/20 Research, Inc.', Truncated_Name__c ='20/20 Research', New_Client_Vendor__c ='New Client/Vendor', Mapped_Account_Name__c =acct1.Name, Mapped_Account_Id__c= acct1.id, TPA_Account_Address__c = acct1.id, IMS_Client_Names__c = '20/20 Research Inc."0017000000SlSGAAA3"', IMS_Total_Clients__c = '20/20 Research Inc."0017000000SlSGAAA3"');
        TPA_AMA_Client_Vendor_Match__c ob2 = new TPA_AMA_Client_Vendor_Match__c(Client_Name__c ='20/20 Research', Truncated_Name__c ='20/20 Research', New_Client_Vendor__c ='New Client/Vendor', Mapped_Account_Name__c =acct2.Name, Mapped_Account_Id__c= acct2.id, TPA_Account_Address__c = acct2.id, IMS_Client_Names__c = '20/20 Research Inc."0017000000SlSGAAA3"', IMS_Total_Clients__c = '20/20 Research Inc."0017000000SlSGAAA3"');
        clientVendorMatchList.add(ob1);
        clientVendorMatchList.add(ob2);
        insert clientVendorMatchList;
        
        TPA_AMA_Settings__c amaSetting = new TPA_AMA_Settings__c(Name = 'TPA AMA Setting',Dev_Mail_ID__c='neha.bansal@metacube.com;test@gmail.com');
        insert amaSetting;
        
        isBatchProcessing = CNT_TPA_NewClientVendorMatch.isBatchProcessing;
        
    }
    
    @isTest static void testcases1(){
        
        amaControllerObj =  new CNT_TPA_NewClientVendorMatch();
        PageReference pageRef = Page.VFP_TPA_NewClientVendorMatch;
        Test.setCurrentPage(pageRef);
        
        test.startTest();
        List<TPA_AMA_Client_Vendor_Match__c> amaMatchRecord = [select id, Client_Name__c, Client_Services_On_Behalf_Of__c, IMS_Client_Names__c, IMS_Total_Clients__c, Mapped_Account_Id__c, Mapped_Account_Name__c, New_Client_Vendor__c, TPA_Account_Address__c, Truncated_Name__c from TPA_AMA_Client_Vendor_Match__c  where Client_Name__c ='20/20 Research, Inc.' ];
        String amaMatchRecordToupdate = JSON.serialize(amaMatchRecord.get(0));
        CNT_TPA_NewClientVendorMatch.updateRecord(amaMatchRecordToupdate);
        CNT_TPA_NewClientVendorMatch.updateMultipleRecord(JSON.serialize(amaMatchRecord));
        
        createTestData();
        CNT_TPA_NewClientVendorMatch.saveMapping(serializeMapRecord);
        (new CNT_TPA_NewClientVendorMatch()).getClientVendorMatch();
        test.stopTest();
    }
    
      
    @isTest static void testcases2(){
        
        amaControllerObj =  new CNT_TPA_NewClientVendorMatch();
        PageReference pageRef = Page.VFP_TPA_NewClientVendorMatch;
        Test.setCurrentPage(pageRef);
        
        test.startTest();
        List<TPA_AMA_Client_Vendor_Match__c> amaMatchRecord = [select id, Client_Name__c, Client_Services_On_Behalf_Of__c, IMS_Client_Names__c, IMS_Total_Clients__c, Mapped_Account_Id__c, Mapped_Account_Name__c, New_Client_Vendor__c, TPA_Account_Address__c, Truncated_Name__c from TPA_AMA_Client_Vendor_Match__c where Client_Name__c ='20/20 Research'];
        String amaMAtchRecordToupdate = JSON.serialize(amaMatchRecord.get(0));
        CNT_TPA_NewClientVendorMatch.updateRecord(amaMAtchRecordToupdate);
        CNT_TPA_NewClientVendorMatch.updateMultipleRecord(JSON.serialize(amaMatchRecord));
        
        createTestData2();
        CNT_TPA_NewClientVendorMatch.saveMapping(serializeMapRecord);
        test.stopTest();
    }
    
    
  
}