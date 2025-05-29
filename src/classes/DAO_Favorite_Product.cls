/**
 * This is OpportunityLineItem Domain class.
 * version : 1.0
 */
public class DAO_Favorite_Product extends fflib_SObjectDomain {
	/**
     * Constructor of this class
     * @params sObjectList List<Opportunity>
     */
    public DAO_Favorite_Product(List<Favorite_Product__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Favorite_Product(sObjectList);
        }
    }
    
    /**
     * This method used to create list of Favorite Products
     * @params  List<Favorite_Product__c> createfavoriteProductList
     */
    public static void createFavoriteProduct(List<Favorite_Product__c> createfavoriteProductList) {
        List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().getUserFavoriteProducts();
        CRM_Config__c  crmConfig = CRM_Config__c.getOrgDefaults();
        Decimal favouriteLimit = crmConfig.Favourite_Products_Limit__c;
        if(favoriteProductList.size() >= favouriteLimit) {
            throw new DAO_Favorite_Product_Exception(new List<String>{CON_CRM.FAVOURITE_PRODUCT_LIMIT_ERROR + Integer.valueOf(favouriteLimit)});
        }
        DAOH_Favorite_Product.createFavoriteProductRecords(createfavoriteProductList);
    }
    
    /**
     * This method used to delete list of Favorite Products
     * @params  List<Favorite_Product__c> favoriteProductDeleteList
     */
    public static void deleteFavoriteProduct(List<Favorite_Product__c> favoriteProductDeleteList) {
        List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().getUserFavoriteProducts();
        DAOH_Favorite_Product.deleteFavoriteProductRecords(favoriteProductDeleteList, favoriteProductList);
    }
    
    /**
     * Exception class for DAO_Favorite_Product
     */
    public class DAO_Favorite_Product_Exception extends Exception {
        public List<String> errorList = new List<String>();
        
        /**
         * constructor of DAO_Favorite_Product
         */
        public DAO_Favorite_Product_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
}