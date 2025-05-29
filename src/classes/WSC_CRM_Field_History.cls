/**
 * Description:
 * This global Apex class serves as a REST resource for creating history tracking records.
 * It is designed to handle incoming HTTP POST requests for creating history tracking records dynamically.
 * 
 * URL Mapping:
 * The class is mapped to the URL path "/createHistoryTrackingRecords" for handling RESTful requests.
 * @Author: Pramod Kumar
 */
@RestResource(urlMapping='/createHistoryTrackingRecords')
Global without sharing class WSC_CRM_Field_History {
    
    /**
     * Inner Class: RequestPayload
     * 
     * Description:
     * This inner class represents the payload structure for handling history tracking requests.
     * It encapsulates information such as the Salesforce object name, new records, old record map,
     * action user ID, and action timestamp.
     * 
     * Members:
     * - objectName: String - The name of the Salesforce object related to the history tracking.
     * - newRecords: List<SObject> - List of new records triggering history tracking.
     * - oldMap: Map<Id, SObject> - Map of old records before the changes.
     * - actionUserId: String - The user ID performing the action triggering history tracking.
     * - actionTime: Datetime - The timestamp when the action triggering history tracking occurred.
     */
    public class RequestPayload {
        private String objectName;
        private List<SObject> newRecords;
        private Map<Id, SObject> oldMap;
        private String actionUserId;
        private Datetime actionTime;
        
        /**
         * Retrieves the actionUserId of the class instance.
         * @return The current actionUserId of the class instance.
         */
        public string getActionUserId() {
            return actionUserId;
        }
        
        /**
         * Sets a new actionUserId for the class instance.
         * @param actionUserId The new actionUserId to set for the class instance.
         */        
        public void setActionUserId(String actionUserId) {
            this.actionUserId = actionUserId;
        }
        
        /**
         * Retrieves the actionTime of the class instance.
         * @return The current actionTime of the class instance.
         */
        public Datetime getActionTime() {
            return actionTime;
        }
        
        /**
         * Sets a new actionTime for the class instance.
         * @param actionTime The new actionTime to set for the class instance.
         */        
        public void setActionTime(Datetime actionTime) {
            this.actionTime = actionTime;
        }
        
        /**
         * Retrieves the objectName of the class instance.
         * @return The current objectName of the class instance.
         */
        public string getObjectName() {
            return objectName;
        }
        
        /**
         * Sets a new objectName for the class instance.
         * @param objectName The new objectName to set for the class instance.
         */                
        public void setObjectName(String objectName) {
            this.objectName = objectName;
        }
        
        /**
         * Retrieves the newRecords of the class instance.
         * @return The current newRecords of the class instance.
         */
        public List<SObject> getNewRecords() {
            return newRecords;
        }
        
        /**
         * Sets a new newRecords for the class instance.
         * @param newRecords The new newRecords to set for the class instance.
         */         
        public void setNewRecords(List<SObject> newRecords) {
            this.newRecords = newRecords;
        }
        
        /**
         * Retrieves the oldMap of the class instance.
         * @return The current oldMap of the class instance.
         */
        public Map<Id, SObject> getOldMap() {
            return oldMap;
        }
        
        /**
         * Sets a new oldMap for the class instance.
         * @param oldMap The new oldMap to set for the class instance.
         */             
        public void setOldMap(Map<Id, SObject> oldMap) {
            this.oldMap = oldMap;
        }
    }
    
    /**
     * HTTP POST method for the REST resource.
     * This method is responsible for creating history tracking records.
     */
    @HttpPost
    global static void createHistoryTrackingRecords() {
        RequestPayload requestPayload;
        Blob  body = RestContext.request.requestBody;
        if(String.isBlank(body.toString())){
            return;
        } else {
            requestPayload =(RequestPayload) JSON.deserialize(body.toString(), RequestPayload.class);
        }
        SRV_CRM_Field_History fieldTrackerService = SRV_CRM_Field_History.getInstance(requestPayload.getObjectName());
        fieldTrackerService.saveFieldHistories(requestPayload);
    }
}