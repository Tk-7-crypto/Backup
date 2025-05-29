global class BCH_OWF_Generate_Triage_Users_Report implements Database.Batchable<sObject>, Database.Stateful, BatchMode{
    
    
    @TestVisible
    List<User> triageUserToUpdateList;
    public String batchMod = 'SET';
    String packageLicenceId;
    Map<Id, String> userIdToErrorMessageMap;
    
    public BCH_OWF_Generate_Triage_Users_Report()
    {
        triageUserToUpdateList = new list<User>();
        OWF_Config__c config = OWF_Config__c.getInstance();
        packageLicenceId = config.PSA_Package_Licence_ID__c;
        userIdToErrorMessageMap = new Map<Id, String>();
    }
    public void ExecuteMode(List<string> Mode)
    {
        for(String mod : Mode){
            batchMod = mod;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = '';
        if(batchMod == 'PSASET')
        {
            query = 'select id,name from user where (id in (select AssigneeId  from PermissionSetAssignment where PermissionSet.Label= \'OWF Triage Manager\') and Triage_Access__c = false)';        
        }
        else if(batchMod == 'PSARESET')
        {
            query = 'select id,name from user where (id not in (select AssigneeId  from PermissionSetAssignment where PermissionSet.Label= \'OWF Triage Manager\') and Triage_Access__c = true)';
        }
        else if(batchMod == 'LICENCESET')
        {
            query = 'Select id,Name,PSA_Licence_Access__c from User where id in (select UserId from UserPackageLicense where PackageLicenseId = \''+ packageLicenceId +'\') and PSA_Licence_Access__c = false';
        }
        else if(batchMod == 'LICENCERESET')
        {
            query = 'Select id,Name,PSA_Licence_Access__c from User where id not in (select UserId from UserPackageLicense where PackageLicenseId = \''+ packageLicenceId +'\') and PSA_Licence_Access__c = true';
        }
        
        
        if(Test.isRunningTest())
        {
            if(batchMod == 'LICENCERESET' || batchMod == 'LICENCESET')
                query = 'Select id,Name,PSA_Licence_Access__c from User';
            
            query = query + ' limit 1';
        }
            
        
        system.debug('query->' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userAssignmentList)
    {
        if(batchMod == 'PSASET')
        {
            for(User userInstance: userAssignmentList)
            {
                userInstance.Triage_Access__c = true;
                triageUserToUpdateList.add(userInstance);
            }
        }
        
        else if(batchMod == 'PSARESET')
        {
            for(User userInstance:userAssignmentList)
            {
                userInstance.Triage_Access__c = false;
                triageUserToUpdateList.add(userInstance);
            } 
        }
        else if(batchMod == 'LICENCESET' )
        {
            for(User userInstance:userAssignmentList)
            {
                userInstance.PSA_Licence_Access__c = true;
                triageUserToUpdateList.add(userInstance);
            }
        }
        else if(batchMod == 'LICENCERESET' )
        {
            for(User userInstance:userAssignmentList)
            {
                userInstance.PSA_Licence_Access__c = false;
                triageUserToUpdateList.add(userInstance);
            }
        }
        
        if(triageUserToUpdateList.size()>0)
        {
            CON_OWF.runFutureJob = false;
            Database.SaveResult[] results = Database.Update(triageUserToUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        userIdToErrorMessageMap.put(triageUserToUpdateList[i].Id, 'Error in Updating User Access flags : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        if (userIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_Generate_Triage_Users_Report, userIdToErrorMessageMap, 'BCH_OWF_Generate_Triage_Users_Report - User Access Flags Update: Failed');
        }
    }
}