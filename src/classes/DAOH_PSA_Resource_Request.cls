/**
* This is Resource Request trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Resource_Request {

    /**
    * This method is used to copy  Service Line Lead field from the Project while inserting a new Resource Request with blank Po
    * @params  newList List<pse__Resource_Request__c>
    * @return  void
    */
    public static void updateRRWhileInsert(List<pse__Resource_Request__c> newList,Map<String,Set<String>> methodToRecordTypeMap) {
        
        Set<Id> projectIdSet = new Set<Id>();
        for(pse__Resource_Request__c resourcerequest : newList) {  

            if ( methodToRecordTypeMap.get('updateRRWhileInsert') == null || !methodToRecordTypeMap.get('updateRRWhileInsert').contains(Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosById().get(resourcerequest.RecordTypeId).getDeveloperName()) ) {
                continue;
            }   

            if (resourcerequest.pse__Project__c != null) {
                projectIdSet.add(resourcerequest.pse__Project__c); 
            }      
        }      
  
        if (!projectIdSet.isEmpty()) {
            Map<Id, pse__Proj__c> projectMap = new SLT_Project(false,false).getProjectById(projectIdSet,new Set<String> {'Id','Name','Service_Line_Lead__c','pse__Project_Manager__c'});              
        
        for (pse__Resource_Request__c resourcerequest : newList) {

                pse__Proj__c tempProj = projectMap.get(resourcerequest.pse__Project__c);
                if (tempProj != null && tempProj.Service_Line_Lead__c != null) {
                    resourcerequest.Project_Manager__c =  tempProj.pse__Project_Manager__c;
                    resourcerequest.Service_Line_Lead__c =  tempProj.Service_Line_Lead__c;
                }    
            }     
        }
    }
       public static void updateResourceRequestStatus(List<pse__Resource_Request__c> newList, Map<Id,pse__Resource_Request__c> existingRecords){
        for(pse__Resource_Request__c resourceRequest : newList){
            if(resourceRequest.RecordTypeId == CON_PSA.RESOURCE_REQUEST_REC_TYPE_ID_RDS_REQUEST 
               && resourceRequest.pse__Resource_Held__c == true ){
               if (trigger.isInsert || (trigger.isUpdate && resourceRequest.pse__Resource_Held__c != existingRecords.get(resourceRequest.Id).pse__Resource_Held__c)) {
                       resourceRequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_HOLD;
                   }
               }
       }
    } 
}