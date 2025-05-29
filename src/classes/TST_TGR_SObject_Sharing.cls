/**
* This test class is used to test all methods in SObject Sharing trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_SObject_Sharing {
    /**
	* This method is used to setup data for all methods.
	*/
    @testSetup
    static void dataSetup() {
        list<Territory2Model> terModel = [Select Id From Territory2Model Where Name = 'Total Business Units'];
        Id terModelId = terModel[0].Id;
        
        list<Territory2Type> terType   = [SELECT id, DeveloperName from Territory2Type limit 1];
        Id terTypeId = terType[0].id;
        
        Territory2 ter1 = new Territory2(name ='test@1', DeveloperName ='test545', Territory2TypeId = terTypeId, 
		Territory2ModelId = terModelId, Legacy_Id__c ='A1', Included_in_Custom_Sharing__c = true);
		insert ter1;
        
        insertSObjectSharing();
        
    }
    
    @future
    private static void insertSObjectSharing(){        
        List<SObject_Sharing__c> insertSObjectSharingList = new List<SObject_Sharing__c>();
        
        SObject_Sharing__c sObjSharing = new SObject_Sharing__c(Enable_Sharing_Calculation__c =true, 
                                         Parent_Sobject__c = 'Apttus__APTS_Agreement__c', Sharing_Territory_Label__c ='Opportunity');
        //insert sObjSharing;
        
        SObject_Sharing__c sObjSharing2 = new SObject_Sharing__c(Enable_Sharing_Calculation__c =false, 
                                         Parent_Sobject__c = 'Apttus__APTS_Agreement__c', Sharing_Territory_Label__c ='Opportunity');
        
        insertSObjectSharingList.add(sObjSharing);
        insertSObjectSharingList.add(sObjSharing2);
        insert insertSObjectSharingList;
    }
    
    static testMethod void testSObjectSharingUpdate() {
        test.startTest();
        List<SObject_Sharing__c> sObjSharingList = [Select Id, Enable_Sharing_Calculation__c, Parent_Sobject__c, Sharing_Territory_Label__c From SObject_Sharing__c where name like 'test@%'];
        List<SObject_Sharing__c> updateSObjSharingList = new List<SObject_Sharing__c>();
        System.debug('sObjSharingList : '+sObjSharingList);
        for(SObject_Sharing__c sos: sObjSharingList){
            if(!sos.Enable_Sharing_Calculation__c){
                sos.Enable_Sharing_Calculation__c = true;
                sos.Parent_Sobject__c = 'Apttus__APTS_LEAD__c';
                sos.Sharing_Territory_Label__c = 'Parent_LEAD_Territory__c';
                updateSObjSharingList.add(sos);
            }            
        }
        update updateSObjSharingList;
        test.stopTest();
    }

}