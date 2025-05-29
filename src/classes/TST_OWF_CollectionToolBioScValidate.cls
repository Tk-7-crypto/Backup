@istest
public class TST_OWF_CollectionToolBioScValidate {
  public static List<OWF_GenericCollectionToolHelper.ValidationRule> validationRules;  
  @testSetup
  private static void setupData() {
      Test.startTest();
      Account acc = UTL_TestData.createAccount();
      insert acc;        
      Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
      insert opp;
      pse__Grp__c grp = UTL_OWF_TestData.createGroup();
      insert grp;
      OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
      insert owfConfig;
      
      Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
      bidHistory.Q2_Business_Area__c = 'BioSciences';
      bidHistory.Bid_Type__c = 'Initial';
      bidHistory.Study_Number__c='02';
      insert bidHistory;      
      setValidationRuleAttribute(bidHistory.Id);   
      String siteValue = 'Indianapolis - ADME';
      String productcode = 'test';
      if(validationRules != null) {
          List<String> sapcode = validationRules[0]?.ruleAttributes[0]?.split('#');
          siteValue = sapcode[0];
          productcode = sapcode[1].split(',')[0]; 
      }
      list<Product2> productList = new list<Product2>();
      Product2 product = UTL_TestData.createProduct();
      product.SAP_Code__c = productcode;
      product.ProductCode = productcode;
      productList.add(product);      
      Product2 product1 = UTL_TestData.createProduct();
      product1.SAP_Code__c = 'testsapcode';
      product1.ProductCode = 'testsapcode';
      productList.add(product1);
      insert productList;
      
      List<CollectionTool__c> listCollectionToolData = new List<CollectionTool__c>();
      CollectionTool__c collectionTool =  UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      collectionTool.Site_Global__c = siteValue;
      listCollectionToolData.add(collectionTool);
      
      CollectionTool__c collectionTool2 = UTL_OWF_TestData.createCollectionTool(bidHistory.Id,product.id);
      collectionTool2.Site_Global__c=siteValue;
      listCollectionToolData.add(collectionTool2);
      insert listCollectionToolData;        
      
      Test.stopTest();        
  }
  private static void setValidationRuleAttribute(String bidHistoryId) {
      OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistoryId, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE);
      if(helper.config.validationRule != null) {
          validationRules = helper.config.validationRule?.validationRules;            
      }
  }
  
  @istest   
  public static void validateServiceLinePositive(){       
      Bid_History__c bidHistory = [Select Id from  Bid_History__c where RecordType.name = : CON_OWF.RECORD_TYPE_Q2_SOLUTION LIMIT 1];
      setValidationRuleAttribute(bidHistory.Id);
      List<CollectionTool__c> collectionTool  = [Select Id,ServiceLine__c,Site_Global__c from  CollectionTool__c where Bid_History__c =: bidHistory.Id];        
      Test.startTest();
      OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE);
      OWF_CollectionToolBioSciencesValidate obj = new OWF_CollectionToolBioSciencesValidate();            
      Set<String> errors = obj.validate(helper.config, collectionTool);
      Test.stopTest();       
      System.assertEquals(0, errors.size());
      
  }
  @istest
  public static void validateServiceLine2(){
      
      Bid_History__c bidHistory = [Select Id from  Bid_History__c where RecordType.name = : CON_OWF.RECORD_TYPE_Q2_SOLUTION LIMIT 1];
      List<CollectionTool__c> collectionTool  = [Select Id,ServiceLine__c,Site_Global__c from  CollectionTool__c where Bid_History__c =: bidHistory.Id ];
      setValidationRuleAttribute(bidHistory.Id);
      collectionTool[0].ServiceLine__c = [Select Id from Product2 Where SAP_Code__c = 'testsapcode'].Id;
      Test.startTest();
      OWF_GenericCollectionToolHelper helper = new OWF_GenericCollectionToolHelper(bidHistory.Id, CNT_OWF_GenericCollectionTool.MDT_CONFIG_NAME_Q2SOLUTIONS_BIOSCIENCE);
      OWF_CollectionToolBioSciencesValidate obj = new    OWF_CollectionToolBioSciencesValidate();
      Set<String> errors = obj.validate(helper.config,collectionTool);
      Test.stopTest(); 
      if(validationRules != null) {
          System.assertEquals(1, errors.size());
      } else {
          System.assertEquals(0, errors.size());
      }
    }
}