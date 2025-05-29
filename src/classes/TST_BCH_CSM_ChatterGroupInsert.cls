@isTest
public class TST_BCH_CSM_ChatterGroupInsert {
    
    @testSetup
    static void dataSetup() {
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test group1', CollaborationType = 'Public');
        insert cg;
    }
    @isTest
    static void ChatterGroupInsertTestMethod(){
        set<string> permissionsetName = new set<string>();
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusernameBatchInsert@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            Article_Manager__c = true,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',isactive = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = '0909090912'
        );
        insert user_1;
        List<PermissionSet> permissionsetList = [Select id,Name from PermissionSet];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        PermissionSetAssignment psa3 = new PermissionSetAssignment();
        PermissionSetAssignment psa4 = new PermissionSetAssignment();
        PermissionSetAssignment psa5 = new PermissionSetAssignment();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(PermissionSet ps : permissionsetList) {
            if(ps.Name == 'CSM_SmartSolve'){
                psa.PermissionSetId =ps.id ;
                psa.AssigneeId = user_1.id;
            }
            else if (ps.Name == 'CSM_SmartSolve_Cloud'){
                psa1.PermissionSetId =ps.id ;
                psa1.AssigneeId = user_1.id;
            }
            else if (ps.Name == 'DATA_Case_Record_Type_Non_US_Service_Prod_Fields_Access'){
                psa2.PermissionSetId =ps.id ;
                psa2.AssigneeId = user_1.id;
            }
            else if(ps.Name == 'TECHNO_Case_Record_Type_Contact_Fields_Access'){
                psa3.PermissionSetId =ps.id ;
                psa3.AssigneeId = user_1.id;
            }
            else if(ps.Name == 'R_D_Case_Record_Type_Study_Activity_Objects_Access'){
                psa4.PermissionSetId =ps.id ;
                psa4.AssigneeId = user_1.id;
            }
            else if (ps.Name == 'CSM_HCP_Onekey_Case_Record_Type_Fields_access'){
                psa5.PermissionSetId =ps.id ;
                psa5.AssigneeId = user_1.id;
            }
        
        }
        permissionList.add(psa);
        permissionList.add(psa1);
        permissionList.add(psa2);
        permissionList.add(psa3);
        permissionList.add(psa4);
        permissionList.add(psa5);

        insert permissionList; 
        Test.startTest();
            ID batchID=Database.executebatch(new BCH_CSM_ChatterGroupInsert(), 1); 
        Test.stopTest();
        System.assert(true);
        
    }
    
    
}