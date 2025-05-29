/**
 * This is Favorite_Product Domain handler class.
 * version : 1.0
 */
public class DAOH_Favorite_Product {
	
    /**
     * Unit of Work instance for CRUD operation
     */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            Favorite_Product__c.SObjectType
        }
    );
    
    /**
     * This method used to create list of OLIs
     * @params  List<Favorite_Product__c> createfavoriteProductList
     */
    public static void createFavoriteProductRecords(List<Favorite_Product__c> createfavoriteProductList) {
        for(Favorite_Product__c favProduct : createfavoriteProductList) {
            favProduct.User__c = UserInfo.getUserId();
            uow.registerNew(favProduct);
        }
        uow.commitWork();
    }
    
    /**
     * This method used to delete list of OLIs
     * @params  List<Favorite_Product__c> favoriteProductDeleteList
     */
    public static void deleteFavoriteProductRecords(List<Favorite_Product__c> favoriteProductDeleteList, List<Favorite_Product__c> favoriteProductList) {
        List<String> errorMsgList = new List<String>();
        for(Favorite_Product__c favProduct : favoriteProductList) {
            for(Favorite_Product__c deleteFavouriteProduct : favoriteProductDeleteList) {
                if(deleteFavouriteProduct.Product__c == favProduct.Product__c) {
                    uow.registerDeleted(favProduct);
                }
            }
        }
        uow.commitWork();
    }
}