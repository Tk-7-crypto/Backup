/*
 * Version       : 1.0
 * Description   : Service Class for Product Search
 */
global class SRV_CRM_Product {
    
    /**
     * service method used to get field detail of sobject
     * @params  String objectName
     * @params  List<String> fieldAPINameList
     * @return  List<UTL_Sobject.ObjectFieldsWrapper>
     */
    public static List<ObjectFieldsWrapper> getProductFieldsDetail(String objectName, List<String> fieldAPINameList) {
        List<ObjectFieldsWrapper> objFieldsWrapperList = new List<ObjectFieldsWrapper>();
        try {
            objFieldsWrapperList = new UTL_Sobject(objectName).getSobjectFieldDetails(fieldAPINameList);
        } catch(Exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new ProductServiceException(new List<String>{errMsg});
        }  
        return objFieldsWrapperList;
    }
    
    // Exception Class for Product Service
    public Class ProductServiceException extends Exception {
        
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public ProductServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
    
    /**
     * This method get product Records according to filter condition.
     * @params  Set<String> fieldSet
     * @params  String filterCondition
     * @return  List<Product2>
     */
    public static List<Product2> getProductsWithFilter(Set<String> fieldSet, String filterCondition) {
        List<Product2> productList = new List<Product2>();
        try {
            SLT_Product2 slt = new SLT_Product2();
            productList = slt.getProductWithFilter(fieldSet, filterCondition);
        } catch(Exception ex) {
            throw new ProductServiceException(new List<String>{ex.getMessage()});
        }   
        return productList;
    }
}