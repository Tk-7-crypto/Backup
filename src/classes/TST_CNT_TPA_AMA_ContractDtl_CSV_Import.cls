/*
*@Author  : Supriya Johhari
*@Purpose : 1. Test class for Controller  CNT_TPA_AMA_ContractDtl_CSV_Import page 
               to check the process of csv data upload for AMA.     
*/
@isTest(seeAllData=false)
public class TST_CNT_TPA_AMA_ContractDtl_CSV_Import {
  
    private static AMA_Contract_Detail__c contractDetail;
    private static CNT_TPA_AMA_ContractDtl_CSV_Import amaContractDetailCSVController ;
    private static String clientListCSV ;
    private static String clientListCSVWithMultipleContractType ;
    private static String lettershopListCSV ;
    private static String invalidDateCSV ;
    private static String invalidHeaderSetCSV ;
    private static String invalidMaxlengthOfClientListCSV ;
    private static String invalidFormatOfClientListCSV ;
    
    
    public static void createTestData() {
        amaContractDetailCSVController = new CNT_TPA_AMA_ContractDtl_CSV_Import();
        clientListCSV = 'CLIENT,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'abc,rtf,,,,,,,,'+'\r\n'+'"Abbie,tup","tyf,LLc","rty,abc",biotech firm,11/30/1992,tyu,Y,False,loc,uop';
        clientListCSVWithMultipleContractType = 'CLIENT,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'abc,rtf,,,,,,,,'+'\r\n'+'"Abbie,tup","tyf,LLc","rty,abc","tyu,aba",11/30/1992,tyu,Y,False,loc,uop';
        lettershopListCSV ='LETTERSHOP,DBL,SERVICES ON BEHALF OF,RECORD COUNT,CONTRACT END DATE,SPECIAL TERMS/CONDITIONS'+'\r\n'+'"Harte-Hanks,tfo",DMD,,';
        invalidDateCSV= 'CLIENT,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'abc,rtf,,,28/15/1997,,,x,,';
        invalidHeaderSetCSV = 'CLIENT name,DBL_hty,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'Metacube,IMS,n';
        invalidMaxlengthOfClientListCSV = 'CLIENT,DBL,SERVICES ON BEHALF OF,CONTRACT TYPE,CONTRACT END DATE,RECORD COUNT,MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'abc,rtfaaaaaaaaaaaaaaaaaaaajayababagsbsgabsskhsgsbsgsnamshsfsvssnmss,,,,,,,,'+'\r\n'+'"Abbie,tup","tyf,LLc","rty,abc",tyu,11/30/1992,tyu,Y,False,loc,uop';
        invalidFormatOfClientListCSV = 'CLIENT DBL SERVICES ON BEHALF OF-CONTRACT TYPE-CONTRACT END DATE-RECORD COUNT-MAX FEE REACHED,OFFSHORE APPROVAL,OFFSHORE LOCATION,SPECIAL TERMS/CONDITIONS'+'\r\n'+'abc,25/20,,,,,,'+'\r\n'+'"Abbie,tup","tyf,LLc","rty,abc",tyu,11/30/1992,tyu,Y,False,loc,uop';
    }    
    /**
    * Setup test data required to run tests in a data independent fashion
    */    
    @testSetup static void setup() {
        List<TPA_AMA_Contract_Type__c> accts = new List<TPA_AMA_Contract_Type__c>();
        
        TPA_AMA_Contract_Type__c ob1 = new TPA_AMA_Contract_Type__c(Name='Contract Sales Force',AMA_Contract_Type__c='Contract Sales Force',Contract_Type_Possible_Names__c ='Start Up II - Pharmaceutical;Start-Up II - Pharmaceutical');
        accts.add(ob1);
        insert accts;
        TPA_AMA_Settings__c amaSetting = new TPA_AMA_Settings__c(Name = 'TPA Setting',Dev_Mail_ID__c='neha.bansal@metacube.com;test@gmail.com');
        insert amaSetting;
        
        /*
        // Fetching the resource
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name ='AMACSVFileForClientList'];
        String URL;
        // Checking if the result is returned or not
        if(resourceList.size() == 1) {
        
            // Getting namespace
            String namespace = resourceList[0].NamespacePrefix;
            // Resource URL
            URL ='/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + 'AMACSVFileForClientList'; 
        }
        
        PageReference pr = new PageReference(URL);
        csv = pr.getContent().toString();
        
        */
    }
    
    @isTest static void testcases_clientListUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = clientListCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        Blob bodyBlob=Blob.valueOf(clientListCSV);
        amaContractDetailCSVController.csvFileBody = bodyBlob;
        amaContractDetailCSVController.fileName='Test AMA contract-client-lists.csv';
        amaContractDetailCSVController.successRecordAsString = 'TPA AMA Contract Success records\r\n\nContract List Type: Client List\r\n\nTotal Success records: 2';
        amaContractDetailCSVController.errorRecordAsString = 'failure Data';
        amaContractDetailCSVController.readFromFile();
        contractDetail = new AMA_Contract_Detail__c();
        //contractDetail.Client_Name__c = 'ZS Associate';
        contractDetail.DBL__c = 'IMS';
        amaContractDetailCSVController.lstContracts.add(contractDetail);
        amaContractDetailCSVController.toDisplay.add(contractDetail);
        amaContractDetailCSVController.First();
        amaContractDetailCSVController.Last();
        amaContractDetailCSVController.Previous();
        amaContractDetailCSVController.Next();
        amaContractDetailCSVController.getHasNext();
        amaContractDetailCSVController.getHasPrevious();
        amaContractDetailCSVController.getPageNumber();
        amaContractDetailCSVController.getChangeListSize();
        amaContractDetailCSVController.getTotalPages();
        amaContractDetailCSVController.saveData();
        test.stopTest();
        list<Apexpages.Message> msgs = ApexPages.getMessages();
        system.debug('msgs.size(): '+msgs.size());
        system.debug('msgs = '+msgs);
        // system.assertEquals(true, msgs.size() == 0); 
    }
    
    @isTest static void testcases_clientListWithMultipleContractType(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = clientListCSVWithMultipleContractType;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        Blob bodyBlob=Blob.valueOf(clientListCSVWithMultipleContractType);
        amaContractDetailCSVController.csvFileBody = bodyBlob;
        amaContractDetailCSVController.fileName='Test AMA contract-client-lists.csv'; 
        amaContractDetailCSVController.readFromFile();
        contractDetail = new AMA_Contract_Detail__c();
        //contractDetail.Client_Name__c = 'ZS Associate';
        contractDetail.DBL__c = 'IMS';
        amaContractDetailCSVController.lstContracts.add(contractDetail);
        amaContractDetailCSVController.toDisplay.add(contractDetail);
        test.stopTest();
        list<Apexpages.Message> msgs = ApexPages.getMessages();
        system.debug('msgs.size(): '+msgs.size());
        system.debug('msgs = '+msgs);
        //system.assertEquals(true, msgs.size() == 0); 
    }
    
    
    @isTest static void testcases_letterShopListtUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = lettershopListCSV;
        amaContractDetailCSVController.contractListType = 'Lettershop';
        amaContractDetailCSVController.hiddenContractListType = 'Lettershop';
        Blob bodyBlob=Blob.valueOf(lettershopListCSV);
        amaContractDetailCSVController.csvFileBody = bodyBlob;
        amaContractDetailCSVController.fileName='Test AMA contract-client-lists.csv';
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.errorLogs.add(new CNT_TPA_AMA_ContractDtl_CSV_Import.ArrayWrapper(2,'testRecord','testErrMsg'));
        amaContractDetailCSVController.toDisplayErrorLogs.add(new CNT_TPA_AMA_ContractDtl_CSV_Import.ArrayWrapper(2,'testRecord','testErrMsg'));
        amaContractDetailCSVController.FirstForErrorLogs();
        amaContractDetailCSVController.LastForErrorLogs();
        amaContractDetailCSVController.PreviousForErrorLogs();
        amaContractDetailCSVController.NextForErrorLogs();
        amaContractDetailCSVController.getHasNextForErrorLogs();
        amaContractDetailCSVController.getHasPreviousForErrorLogs();
        amaContractDetailCSVController.getPageNumberForErrorLogs();
        amaContractDetailCSVController.getChangeListSizeForErrorLogs();
        amaContractDetailCSVController.getTotalPagesForErrorLogs();
        amaContractDetailCSVController.getCpuTime();
        amaContractDetailCSVController.saveData();
        amaContractDetailCSVController.blobToString(bodyBlob, 'ISO-8859-1');
        test.stopTest();
        //system.assertEquals(true,amaContractDetailCSVController.toDisplayErrorLogs.size() > 0);
    }
    
 
    @isTest static void testcases_invalidDateListUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = invalidDateCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.saveData();
        test.stopTest();
    }
    
    @isTest static void testcases_invalidHeaderSetListUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = invalidHeaderSetCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.saveData();
        test.stopTest();
    }
    
       
    @isTest static void testcases_wrongTypeOfFileUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = lettershopListCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.saveData();
        test.stopTest();
    }
    
    @isTest static void testcases_InvalidMaxlengthForFieldValueOfCSVFileUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = invalidMaxlengthOfClientListCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        amaContractDetailCSVController.hiddenContractListType='Client List';
        Blob bodyBlob=Blob.valueOf(invalidMaxlengthOfClientListCSV);
        amaContractDetailCSVController.csvFileBody = bodyBlob;
        amaContractDetailCSVController.fileName='Test AMA contract-client-lists.csv'; 
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.saveData();
        test.stopTest();
    }
    
    @isTest static void testcases_InvalidFormatOfCSVFileUploaded(){
        createTestData();
        test.startTest();
        amaContractDetailCSVController.contractDataAsString = invalidFormatOfClientListCSV;
        amaContractDetailCSVController.contractListType = 'Client List';
        //amaContractDetailCSVController.hiddenContractListType='Client List';
        Blob bodyBlob=Blob.valueOf(invalidFormatOfClientListCSV);
        amaContractDetailCSVController.csvFileBody = bodyBlob;
        amaContractDetailCSVController.fileName='Test AMA contract-client-lists.csv'; 
        amaContractDetailCSVController.readFromFile();
        amaContractDetailCSVController.saveData();      
        test.stopTest();
    }
    
}