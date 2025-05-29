/*
 * Version       : 1.0
 * Description   : Service Class for Default Product Search Filter
 */
global class SRV_CRM_Default_Product_Search {
    
    /**
     * service method used to update Default Product Search Filter
     * @params  List<Default_Product_Search__c> defaultProductSearchList
     */
    public static void updateDefaultProductSearchFilter(List<Default_Product_Search__c> defaultProductSearchList) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Default_Product_Search__c.SobjectType});
            for(Default_Product_Search__c defaultProductSearch : defaultProductSearchList) {
                if(defaultProductSearch.Id == null) {
                    uow.registerNew(defaultProductSearch);
                } else {
                    uow.registerDirty(defaultProductSearch);
                }
            }
            uow.commitWork(); 
        } catch(Exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new DefaultProductSearchException(new List<String>{errMsg});
        }  
    }
    
    /**
     * service method used to get Default Product Search Filter
     * @params  Set<Id> userIdSet
     * @return  List<Default_Product_Search__c>
     */
    public static List<Default_Product_Search__c> getDefaultProductSearchFilter(Set<Id> userIdSet, Set<String> defaultProductfieldSet) {
        List<Default_Product_Search__c> defaultProductSearchList = new List<Default_Product_Search__c>();
        try {
            defaultProductSearchList = new SLT_Default_Product_Search().getDefaultProductSearchByUsers(userIdSet, defaultProductfieldSet);
        } catch(Exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new DefaultProductSearchException(new List<String>{errMsg});
        }  
        return defaultProductSearchList;
    }
    
    // Exception Class for Default Product Search
    public Class DefaultProductSearchException extends Exception {
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public DefaultProductSearchException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}