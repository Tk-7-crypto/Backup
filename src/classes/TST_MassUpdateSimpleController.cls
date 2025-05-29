/**
* This class contains unit tests for validating the behavior of MassUpdateController
* and triggers.
*/
@isTest
private class TST_MassUpdateSimpleController {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Contact contact = UTL_TestData.createContact(acc.Id);
        insert contact;    
    }
    
    static testMethod void testSingleUpdate() {
        Opportunity o = new Opportunity();
        List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        setCtr.setSelected(new Opportunity[]{o});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assertEquals(1, controller.getRecordSize());
        System.assert(controller.getFieldTypeOptions().size()>1);
        System.assertEquals(1, controller.objsToUpdate.size());
        
        String value = '123test';
        controller.fieldName='name';
        controller.valueToUpdate=value;	
        controller.step4();
        controller.step5();
        
        System.assert(o.name==value);
        
        value ='123';
        controller.step3();
        controller.fieldName='amount';
        controller.valueToUpdate=value;	
        controller.step4();
        controller.step5();
        
        System.assert(o.amount==decimal.valueOf(value));
        
        // make sure no exception from display tips
        System.assertEquals(controller.getFieldInfoToDisplay()!=null,true);
        
        value ='2009-4-7';
        controller.fieldName='CloseDate';
        controller.valueToUpdate=value;		
        controller.step4();
        controller.step5();
        System.assert(o.CloseDate==Date.valueOf(value));
        
        value ='Closed';
        controller.fieldName='StageName';
        controller.valueToUpdate=value;		
        controller.step4();
        controller.step5();
        System.assert(o.StageName=='Closed');
    }
    
    static testMethod void testLink() {
        Test.startTest();
        Opportunity o = new Opportunity();
        List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        setCtr.setSelected(new Opportunity[]{o});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        
        // verify following exceptions will not cause exception
        System.assert(controller.step1()!=null);
        System.assert(controller.step2()!=null);
        controller.getFieldTypeOptions();
        System.assert(controller.step3()!=null);
        System.assert(controller.step4()!=null);
        System.assert(controller.step5()!=null);
        System.assert(controller.getFieldTypeOptions()!=null);
        Test.stopTest();
    }
    
    static testMethod void testField() {
        Test.startTest();
        List<Opportunity> oppList = new Opportunity[]{};
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assert(controller.cancel()!=null);
        System.assert(controller.getFieldTypeOptions()==null);
        Test.stopTest();
    }
    
    static testMethod void miscTest() {
        Test.startTest();
        List<Opportunity> oppList = new Opportunity[]{};
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assert(controller.getNow(true)!=null);
        System.assert(controller.getNow(false)!=null);
        System.assert(controller.getRecordSize()==0);
        System.assert(controller.getPicklistValues()==null);
        Test.stopTest();
    }
    
    static testMethod void testOpportunityInRelatedList(){
        Test.startTest();
        Opportunity o = new Opportunity();
        List<Opportunity> oppList = [SELECT name, AccountId FROM Opportunity LIMIT 20];
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        Apexpages.currentpage().getparameters().put('id' , oppList.get(0).AccountId);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);  
        ApexPages.Message msg = ApexPages.getMessages()[0];
        System.assertEquals('No record was selected on the list view.  Please click Previous button and select records for mass update.', msg.getDetail());
        setCtr.setSelected(new Opportunity[]{o});
        controller = new MassUpdateSimpleController(setCtr);
        msg = ApexPages.getMessages()[1];
        System.assertEquals('Number of records selected for update: 1', msg.getDetail());
        System.assertEquals('1',controller.getStep());
        System.assertEquals('Opportunity',controller.getsType());
        Test.stopTest();
    }
    
    static testMethod void testGenerateQuery() {
        Test.startTest();
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(contactList);
        Apexpages.currentpage().getparameters().put('id' , contactList.get(0).AccountId);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        setCtr.setSelected(new Contact[]{new Contact()});
        controller = new MassUpdateSimpleController(setCtr);
        Test.stopTest();
    }
    
    static testMethod void testFieldType() {
        Test.startTest();
        List<Opportunity> oppList = [SELECT name, AccountId FROM Opportunity LIMIT 20];
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        controller.fieldType = 'CURRENCY';
        System.assertEquals('true',controller.displayTexField);
        System.assertEquals('false',controller.displayTextArea);
        controller.fieldType = 'TEXTAREA';
        System.assertEquals('true',controller.displayTextArea);
        System.assertEquals('false',controller.displayTexField);
        System.assertEquals('false',controller.displayCheckBox);
        controller.fieldType = 'BOOLEAN';
        System.assertEquals('true',controller.displayCheckBox);
        System.assertEquals('false',controller.displayPicklist);
        controller.fieldType = 'PICKLIST';
        System.assertEquals('true',controller.displayPicklist);
        Test.stopTest();
    }
    
    static testMethod void testLexSteps() {
        Test.startTest();
        List<Opportunity> oppList = [SELECT name, AccountId FROM Opportunity LIMIT 20];
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr); 
        controller.lexstep1();
        controller.lexstep2();
        controller.lexstep3();
        controller.lexstep4();
        controller.lexstep5();
        Test.stopTest();
    }
}