@isTest(SeeAllData=false)
private class TST_TGRH_TPASecDataAsset { 
    @isTest
    private static void testOnAfterInsert(){
        Test.startTest();
        TPA_Request__c tpaRequest = new TPA_Request__c();
        insert tpaRequest;
        TPA_Purpose__c purpose = new TPA_Purpose__c( Request__c = tpaRequest.Id,Name = 'Test Purpose' );
        insert purpose;
        TPA_Data_Asset__c dataAsset = new TPA_Data_Asset__c( hasXponentPlanTrak__c = true,BU__c = 'US',Purpose__c = purpose.Id);
        insert dataAsset;
        TPA_Secondary_Data_Asset__c secDataAsset = new TPA_Secondary_Data_Asset__c( TPA_Data_Asset__c = dataAsset.Id,Secondary_Asset_Name__c = 'Xponent PlanTrak');
        insert secDataAsset;
        try{
            delete secDataAsset;
        }catch(Exception e){
            system.debug(e);
            System.assert(e.getMessage().contains('You do not have necessary permissions to delete this TPA Secondary Data Asset record'));
        }
        Test.stopTest();
        
    }
}