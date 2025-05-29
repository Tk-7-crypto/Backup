@isTest
public class TST_CreateUpdateMetadataUtils {    
    @isTest
    private static void testHandleResult() {
        Metadata.DeployCallback callback = new CreateUpdateMetadataUtils();
        
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

        callback.handleResult(result, context);
    }
    
    @isTest
    private static void testCreateUpdateMetadata() {
        Map<String, Object> maptest = new Map<String, Object>();
        maptest.put('customField__c','New value');
        Metadata.CustomMetadata customMetadata = CreateUpdateMetadataUtils.getCustomMetadata('Test_MetadataAPIName', 
            'Test Label', maptest);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        CreateUpdateMetadataUtils.createUpdateMetadata(mdContainer);
    }
}