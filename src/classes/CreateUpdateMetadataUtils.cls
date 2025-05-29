/*
* This class is used to Create or Update Custom metadata Records
*/
public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    /**
    * This method is called when the asynchronous deployment of custom metadata completes.
    * we can also process on the DeployResult as per the requirement
    * @params Metadata.DeployResult result
    * @params Metadata.DeployCallbackContext context
    */
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);
        } else {
            System.debug(' fail : '+ result);
        }
    }
    
    /**
    * This method is used to create or update the custom metadata.
    * @params Metadata.DeployContainer mdContainer
    */
    public static void createUpdateMetadata(Metadata.DeployContainer mdContainer){
        CreateUpdateMetadataUtils callback = new CreateUpdateMetadataUtils();
        if (!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    
    /**
    * This method is used to get Metadata.CustomMetadata record.
    * @params String fullName (full name of the custom metadata record)
    * @params String label (label of the custom metadata record)
    * @params Map<String, Object> fieldWithValuesMap (this is the map of all the fields with its value of the record)
    */
    public static Metadata.CustomMetadata getCustomMetadata(String fullName, String label, 
        Map<String, Object> fieldWithValuesMap) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        
        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key); 
            customMetadata.values.add(customField);
        }
        return customMetadata;
    }
}