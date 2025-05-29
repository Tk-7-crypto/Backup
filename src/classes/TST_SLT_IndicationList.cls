@isTest
public with sharing class TST_SLT_IndicationList {
    /**
    * @description 
    * @return void 
    **/
    @testSetup static void oppAIMLResultTestSetup() {
        Indication_List__c indicationObj = new Indication_List__c(name='testIndication', Therapy_Area__c='Acute Care');
        insert indicationObj;
        
    }
    /**
    * @description 
    * @return testMethod 
    **/
    static testMethod void getFieldListTest(){
        SLT_IndicationList sltObjectClass = new SLT_IndicationList();
        sltObjectClass.getSObjectFieldList();
        // Its returning null so we didn't added Asserts
    }
    /**
    * @description 
    * @return testMethod 
    **/
    static testMethod void getSobjectTypeTest(){
        SLT_IndicationList sltObjectClass = new SLT_IndicationList();
        System.assertEquals(String.ValueOf(sltObjectClass.getSObjectType()),'Indication_List__c');
    }
    /**
    * @description 
    * @return testMethod 
    **/
    static testMethod void getselectByNameTest(){
        SLT_IndicationList sltObjectClass = new SLT_IndicationList();
        Indication_List__c indicationRec = [SELECT Id,Name,Therapy_Area__c FROM Indication_List__c WHERE name = 'testIndication'];
        Set<String> fieldsToQuery = new Set<String>{'Id', 'Name', 'Therapy_Area__c'};
        List<Indication_List__c> indicationRecLst = sltObjectClass.selectByName(new Set<String>{indicationRec.Name}, fieldsToQuery);
        Map<Id,Indication_List__c> indicationRecMap = sltObjectClass.selectById(new Set<Id>{indicationRec.Id} );
        System.assertEquals(indicationRecLst[0].Name , indicationRec.Name);
        System.assertEquals(indicationRecLst[0].Id , indicationRec.Id);
        System.assertEquals(indicationRecLst[0].Therapy_Area__c , indicationRec.Therapy_Area__c);
    }
}