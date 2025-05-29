public with sharing class CNT_PSA_manageRelatedSystems {
    public CNT_PSA_manageRelatedSystems() {

    }

    @AuraEnabled(cacheable=true)
    public static Map<Id,Project_Related_System__c> getProjectRelatedSystems(Id projectId){
        return new Map<Id,Project_Related_System__c>( new SLT_Project_Related_System().getRelatedSystemsByProject( new Set<Id>{projectId} ) );
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id,PSA_Related_System__c> getPSARelatedSystems(){
        return new Map<Id,PSA_Related_System__c>( new SLT_PSA_Related_System().getAllPSARelatedSystems() );
    }

    @AuraEnabled(cacheable=true)
    public static List<PSA_Related_Systems_Service_Lines__c> getJunctions(){
        return new SLT_PSA_RS_Service_Lines().getAll(); 
    }

    @AuraEnabled(cacheable=false)
    public static String addRelatedSystems(List<Map<String,String>> rows, Id projectId){
        System.debug('addRelatedSystems');
        System.debug('addRelatedSystems:'+rows);
        // Check to see if we have any Project Related Systems already on these ids
        List<Project_Related_System__c> existingProjectSystems = new SLT_Project_Related_System().getRelatedSystemsByProject(new Set<Id>{projectId}, new Set<String>{'PSA_Related_System__c'});
        Set<Id> existingPSASystemIds = new Set<Id>();
        for(Project_Related_System__c prs : existingProjectSystems) {
            existingPSASystemIds.add(prs.PSA_Related_System__c);
        }

        List<Project_Related_System__c> projectSystemsToAdd = new List<Project_Related_System__c>(); 
        for(Map<String,String> row : rows){
            Id psarsId = (Id)row.get('id');
            if( !existingPSASystemIds.contains(psarsId) ){
                projectSystemsToAdd.add(new Project_Related_System__c(
                    Project__c=projectId,
                    PSA_Related_System__c=psarsId,
                    Client_System_Name__c=row.get('clientSystemName'),
                    Hosted_By__c=row.get('hostedBy'),
                    Additional_Info__c=row.get('additionalInfo')
                ));
            }
        }
        
        if(projectSystemsToAdd.size() > 0){
            insert projectSystemsToAdd;
        }

        return 'Success';
    }

    @AuraEnabled(cacheable=false)
    public static String updateRelatedSystems(List<Map<String,String>> rows){
        List<Project_Related_System__c> toUpdate = new List<Project_Related_System__c>();
        for(Map<String,String> row : rows){
            Project_Related_System__c relatedSystem = new Project_Related_System__c(
                Id=row.get('projectRelatedSystem'),
                Project__c=row.get('project'),
                PSA_Related_System__c=row.get('id'),
                Client_System_Name__c=row.get('clientSystemName'),
                Hosted_By__c=row.get('hostedBy'),
                Additional_Info__c=row.get('additionalInfo')
            );
            toUpdate.add(relatedSystem);
        }
        if(toUpdate.size() > 0){
            update toUpdate;
            return 'Success';
        }

        throw new AuraHandledException('Did not find any related systems to update.');
    }

    @AuraEnabled
    public static String removeRelatedSystems(List<Id> systemIds, Id projectId){
        List<Project_Related_System__c> systemsToDelete = new SLT_Project_Related_System().getProjectRelatedSystemsByPSASystem(new Set<Id>(systemIds), projectId, new Set<String>{'Id'});
        if(systemsToDelete.size() > 0){
            delete systemsToDelete;
            return 'Success';
        }
        throw new AuraHandledException('Did not find any related systems to delete.');
    }
}