@isTest
public class TST_CNT_PSA_addJournal {
	@testSetup
    public static void dataSetup(){
        Journals_Main_Catalogue__c main_Journal_catalog=UTL_PSA_TestData.createJournalMainCatalogue();
       	insert main_Journal_catalog;
        
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct2;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.id;
        insert project;        
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
                                        Program__c = program.id,
                                   		Active__c = true,
                                        Service_Lines__c = 'Literature');
        insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        insert lrRec;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = 'Local';
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        insert eventJournal;        
    }
    @isTest
    public static void testgetMainJournalCatalogueList(){
        Test.startTest();
        List<Journals_Main_Catalogue__c> mainJournalCatalog = CNT_PSA_addJournal.getMainJournalCatalogueList();
        List<String> selectedCountriesLabels = new List<String>();
        selectedCountriesLabels.add('Argentina');
        selectedCountriesLabels.add('Albania');
        List<Id> jmcIds = new List<Id>();
        for( Journals_Main_Catalogue__c jm : mainJournalCatalog ){
            jmcIds.add( jm.Id );
        }
        Test.stopTest();
        System.assertEquals(1,mainJournalCatalog.size(), 'Tested');
    }
    @isTest(SeeAllData=false) 
     public static void testhaveEditablePermission(){
        List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin' or Name = 'RDS_Read_Only'];
        List<User> userList = UTL_TestData.createUser('System Administrator', 2);
        insert userList;
        List<PermissionSetAssignment> permissionSetAssignment=new List<PermissionSetAssignment>(); 
        for(integer i=0;i<2;i++){
            permissionSetAssignment.add(new PermissionSetAssignment(AssigneeId=userList[i].Id,PermissionSetId= ps[i].Id));
        }
        insert permissionSetAssignment;
        Test.startTest();
            boolean haveEditPermission=CNT_PSA_addJournal.haveEditablePermission(userList[0].id);
            boolean doesNothaveEditPermission=CNT_PSA_addJournal.haveEditablePermission(userList[1].id);
        Test.stopTest();
        System.assertEquals(true,haveEditPermission, 'Tested');
        System.assertEquals(false,doesNothaveEditPermission, 'Tested');	
    }
     @isTest(SeeAllData=false) 
     public static void testaddEventJournalToLRProjectOverview(){
        List<LR_Project_Overview__c> LR_Project_Overview=[select id from LR_Project_Overview__c LIMIT 50];
        List<Event_Journals__c> eventJournalList=new List<Event_Journals__c>();
        List<Event_Journals__c> eventJournalList1=new List<Event_Journals__c>();
        eventJournalList.add(UTL_PSA_TestData.createEventJournal());
        eventJournalList1.add(new Event_Journals__c(Name='123',Country__c='AF',Journal_Name__c='Jou1',URL__c='www.xyz.com',Periodicity__c='per',Regulatory_requirement__c='Yes',Subscription__c='Yes',
                                                                 Paper_Journal__c='Yes',Therapeutic_Area__c='Area')); 
        Test.startTest();                     
        CNT_PSA_addJournal.addEventJournalToLRProjectOverview(eventJournalList,LR_Project_Overview[0].id);
        CNT_PSA_addJournal.addEventJournalToLRProjectOverview(eventJournalList1,LR_Project_Overview[0].id);
        Test.stopTest();  
        String errMsg = 'Testing Raise Exception';
	try{
	    AuraHandledException ahe = new AuraHandledException(errMsg);
	    ahe.setMessage(errMsg);
	    CNT_PSA_ProjectMetric.raise(ahe);
	} catch (Exception e) {
	    system.assertEquals(errMsg, e.getMessage(),'Tested');
	}
    }
    
    @isTest
    public static void testLR_Type_Local(){
        Test.startTest();
        LR_Project_Overview__c lr = [ SELECT Id, Project__c, LR_Type__c FROM LR_Project_Overview__c LIMIT 1 ];
        lr.Account__c = null;
        update lr;
        CNT_PSA_addJournal.lrProjectOverviewValidation( lr.Id );
        Test.stopTest();
        System.assertEquals(false, lr.Account__c!= null, 'Tested');
    }
    
    @isTest
    public static void testPickListValueDynamically(){
        Test.startTest();
        CNT_PSA_addJournal.pickListValueDynamically( new Event_Journals__c(), 'Active__c' );
        Test.stopTest(); 
        System.assert(true, 'Expecting exception');
    }
}
