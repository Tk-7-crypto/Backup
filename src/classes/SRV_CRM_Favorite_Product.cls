/*
 * Version       : 1.0
 * Description   : Service Class for OpportunityLineItem
 */
public class SRV_CRM_Favorite_Product {
	
    /**
     * This method used to perform CRUD on OLI
     * @params  List<Favorite_Product__c> favoriteProductList
     * @params  String objectName
     * @params  String action
     */
    public static void modifyFavoriteProductRecords(List<Favorite_Product__c> favoriteProductList, String objectName, String action) {
        try {
            if(action == CON_CRM.CREATE_LABEL) {
                DAO_Favorite_Product.createFavoriteProduct(favoriteProductList);
            } else if(action == CON_CRM.DELETE_LABEL) {
                DAO_Favorite_Product.deleteFavoriteProduct(favoriteProductList);
            }
        } catch (DAO_Favorite_Product.DAO_Favorite_Product_Exception ex) {
            throw new SRV_CRM_Favorite_Product_Exception(ex.errorList);
        }
    }
    
    /**
     * Exception class for SRV_CRM_Favorite_Product
     */
    public class SRV_CRM_Favorite_Product_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
         * constructor of SRV_CRM_Favorite_Product_Exception
         */
        public SRV_CRM_Favorite_Product_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
}