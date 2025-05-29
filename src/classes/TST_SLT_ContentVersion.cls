@isTest
private class TST_SLT_ContentVersion {

	  @testSetup
	  static void dataSetup() {
				ContentVersion testContentVersion = new Contentversion();
				testContentVersion.Title = 'CZDSTOU';
				testContentVersion.PathOnClient = 'test';
				testContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
				List<ContentVersion> contentVersionList = new List<ContentVersion>();
				contentVersionList.add(testContentVersion);
				insert contentVersionList;
	  }

      @isTest static void testGetContentVersionByDocumentIds() {

        SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
				Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.VERSION_DATA, CON_CPQ.FILE_TYPE, CON_CPQ.FILE_EXTENSION};
				List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument];

				Test.startTest();
				    List<ContentVersion> contentVersions = sltContentVersion.getContentVersionByDocumentIds(new Set<Id>{contentDocumentList[0].Id}, fieldSet) ;
				Test.stopTest();

				System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
	  }

		@isTest
		private static void testGetContentVersionByContentDocumentId(){
			SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
		
			List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument];
			Test.startTest();
				List<ContentVersion> contentVersions = sltContentVersion.getContentVersionByContentDocumentId(new Set<Id>{contentDocumentList[0].Id}) ;
			Test.stopTest();
			System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
		}
    
    @isTest
    private static void testGetContentVersions() {
        SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument];
        String condition = ' Title like \'%CZDSTOU%\' AND ContentDocumentId IN :docIds';
        
        Test.startTest();
            List<ContentVersion> contentVersions = sltContentVersion.getContentVersions(condition, 
                new Set<Id>{contentDocumentList[0].Id}) ;
        Test.stopTest();
        
        System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
    }
    
    @isTest
    private static void testSelectById() {
        SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
        ContentVersion contentVersion = [SELECT Id FROM ContentVersion where Title like 'CZDSTOU'][0];
        
        Test.startTest();
            List<ContentVersion> contentVersions = sltContentVersion.selectById(new Set<Id>{contentVersion.Id}) ;
        Test.stopTest();
        
        System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
    }
    
    @isTest
    private static void testGetContentVersionFromDocumentId() {
        SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument];
        String condition = ' Title like \'%CZDSTOU%\' AND ContentDocumentId IN :docIds';
        
        Test.startTest();
            List<ContentVersion> contentVersions = sltContentVersion.getContentVersionFromDocumentId(
                new Set<String>{contentDocumentList[0].Id}, new Set<String>{'Id'}) ;
        Test.stopTest();
        
        System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
    }
    
    @isTest
    private static void testGetContentVersionByIds() {
        List<ContentVersion> contentVersion = [SELECT Id, Title FROM ContentVersion LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Title', 'Id'};
        
        Test.startTest();
            List<ContentVersion> contentVersionResult = new SLT_ContentVersion().getContentVersionByIds(new Set<Id>{contentVersion[0].Id}, fieldSet);
        Test.stopTest(); 
        
        System.assertEquals('CZDSTOU', contentVersionResult[0].Title, 'The title should be same');
    }
    @isTest
    static void testGetContentVersionByCondition() {
        List<ContentVersion> contentVersion = [SELECT Id, Title FROM ContentVersion LIMIT 1];
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.TITLE};
        String condition = 'Title = \'' + contentVersion[0].Title + '\'';
        
        Test.startTest();
            List<ContentVersion> contentVersionResult = new SLT_ContentVersion().getContentVersionByCondition(fieldSet, condition);
        Test.stopTest(); 
        System.assertEquals(contentVersion[0].Title, contentVersionResult[0].Title, 'The title should be same');
    }

    @isTest
    static void testgetContentVersionByConditions() {
        List<ContentVersion> contentVersion = [SELECT Id, Title FROM ContentVersion  where Title = 'CZDSTOU' LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Id', 'TITLE'};
        String condition = 'Id IN: IdSet';
        
        Test.startTest();
            List<ContentVersion> contentVersionResult = new SLT_ContentVersion().getContentVersionByCondition(fieldSet, condition, new Set<Id>{contentVersion[0].Id});
        Test.stopTest(); 
        
        System.assertEquals(contentVersion[0].Title, contentVersionResult[0].Title, 'The title should be same');
    }
}