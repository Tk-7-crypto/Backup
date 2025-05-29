public class UTL_ValidationCallback {
    public static  Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
        list <Apttus_Config2.LineItem> allLines = cart.getLineItems();
        list<Apttus_Config2__LineItem__c> allLineItems = UTL_CPQ_ValidationCallback.getLineItems(allLines);        
        return UTL_CPQ_ValidationCallback.productValidation(allLineItems);
    }
}