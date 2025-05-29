global with sharing class CPQ_ValidationCallback implements Apttus_Config2.CustomClass.IValidationCallback2, Apttus_Config2.CustomClass.IValidationCallback3 {

    global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        try {
            return UTL_ValidationCallback.validateCart(cart);
        } Catch(Exception e) {
            return result;
        }
    }
    
    global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
        return new Apttus_Config2.CustomClass.ValidationResult(true);
    }
    
    //Method for Validation Callback 3
    global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.CustomClass.ActionParams params, Apttus_Config2.ProductConfiguration cart) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        try {
            return  UTL_ValidationCallback.validateCart(cart);
        } Catch(Exception e) {
            return result;
        }
    }
	
    //Method for Validation Callback 3
    global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.CustomClass.ActionParams params,
        Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
        return new Apttus_Config2.CustomClass.ValidationResult(true);
    }

    global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2__TempRenew__c> assetItems) {
        return new Apttus_Config2.CustomClass.ValidationResult(true);
    }
	
}
