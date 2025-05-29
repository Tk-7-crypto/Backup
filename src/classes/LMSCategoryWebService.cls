@RestResource(urlMapping='/lmscategory/*')
global with sharing class LMSCategoryWebService {
    
    private static final String ERROR_100 = 'INTERNAL_SERVER_ERROR';
    private static final String ERROR_101 = 'REQUIRED_FIELD_MISSING';
    private static final String ERROR_102 = 'DUPLICATE_DATA';
    private static final String ERROR_103 = 'PRODUCT_CODE_NOT_EXISTS';
    private static final String ERROR_104 = 'RECORD_ID_NOT_EXISTS';
    
    
	@HttpPost
    global static List<Map<String, String>> doPost(String onPointId, String catalog, String productCode) {
        
        RestResponse response = RestContext.response;

        if(String.isBlank(onPointId)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing on point id.');
        }
        
        if(String.isBlank(catalog)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing catalog.');
        }
        
        Id productId;
        
        if(String.isBlank(productCode)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing product code.');
        }else{
            List<Product2> productList = [SELECT Id FROM Product2 WHERE ProductCode = :productCode];
            if(productList.size() > 0){
                productId = productList[0].Id;
            }else{
                response.StatusCode = 400;
            	return getError(ERROR_103, 'Product code does not exists.');
            }
        }

        List<TS_LMS_Category__c> categoryList = [SELECT Id FROM TS_LMS_Category__c  WHERE OnPoint_Skill_Profile_Id__c = :onPointid];
        
        if(categoryList.size() > 0){
            response.StatusCode = 400;
            return getError(ERROR_102, 'On Point Id already exists.');
        }
        
        try{
            TS_LMS_Category__c lmsCategory = new TS_LMS_Category__c();
            lmsCategory.OnPoint_Skill_Profile_Id__c = onPointid;
            lmsCategory.Catalog__c = catalog;
            lmsCategory.Product__c = productId;
            insert lmsCategory;
            response.StatusCode = 201;
            Map<String, String> successMap = new Map<String, String>();
            successMap.put('recordId', lmsCategory.Id);
            return new List<Map<String, String>>{successMap};
        }catch(Exception e){
            response.StatusCode = 500;
            return getError(ERROR_100, e.getMessage());
        }
    }
    
    @HttpPut
    global static List<Map<String, String>> doPut(String recordId, String catalog, String productCode) {
        
        RestResponse response = RestContext.response;

        if(String.isBlank(recordId)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing record Id.');
        }
        
        if(String.isBlank(catalog) && String.isBlank(productCode)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing fields to update.');
        }
        
        List<TS_LMS_Category__c> categoryList = [SELECT Id FROM TS_LMS_Category__c  WHERE Id = :recordId];
        
        if(categoryList.isEmpty()){
            response.StatusCode = 400;
            return getError(ERROR_104, 'Record id does not exist.');
        }
        
        Id productId;
        
        if(!String.isBlank(productCode)){
			List<Product2> productList = [SELECT Id FROM Product2 WHERE ProductCode = :productCode];
            if(productList.size() > 0){
                productId = productList[0].Id;
            }else{
                response.StatusCode = 400;
            	return getError(ERROR_103, 'Product code does not exists.');
            }
        }

        try{
            TS_LMS_Category__c lmsCategory = new TS_LMS_Category__c();
            lmsCategory.Id = categoryList.get(0).Id;

            if(!String.isBlank(catalog))
            	lmsCategory.Catalog__c = catalog;
            
            if(productId != null)
                lmsCategory.Product__c = productId;
            
            upsert lmsCategory;
            
            response.StatusCode = 204;
            Map<String, String> successMap = new Map<String, String>();
            successMap.put('recordId', lmsCategory.Id);
            return new List<Map<String, String>>{successMap};
        }catch(Exception e){
            response.StatusCode = 500;
            return getError(ERROR_100, e.getMessage());
        }
    }
    
    @HttpDelete
    global static List<Map<String, String>> doDelete(){
        RestResponse response = RestContext.response;
        
        String recordId = RestContext.request.params.get('recordId');
        
        if(String.isBlank(recordId)){
			response.StatusCode = 400;
            return getError(ERROR_101, 'Missing record Id.');
        }
        
        List<TS_LMS_Category__c> categoryList = [SELECT Id FROM TS_LMS_Category__c  WHERE Id = :recordId];
        
        if(categoryList.isEmpty()){
            response.StatusCode = 400;
            return getError(ERROR_104, 'Record id does not exist.');
        }else{
           try{
                delete categoryList;
                response.StatusCode = 202;
                Map<String, String> successMap = new Map<String, String>();
                return new List<Map<String, String>>{successMap};
            }catch(Exception e){
                response.StatusCode = 500;
                return getError(ERROR_100, e.getMessage());
            }
        }
    }
    
    private static List<Map<String, String>> getError(String errorCode, String errorMessage){
        Map<String, String> errorMap = new Map<String, String>();
        errorMap.put('errorCode', errorCode);
        errorMap.put('message', errorMessage);
        return new List<Map<String, String>>{errorMap};
    }
}