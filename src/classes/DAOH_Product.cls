public class DAOH_Product {
    
    public static void checkForDuplicacy(List<Product2> newProductList){
        Map<String, Product2> productMap = new Map<String, Product2>();
        Product2 newProductRef = new Product2();
        for(Product2 p : newProductList){
            if(p.SpecificToCSM__c){ 
                string keyName = (p.Name).toUpperCase();
                productMap.put((keyName),p);
                
            }
            
        }
        if(productMap != null){
            for (Product2 productVar : [SELECT Name FROM Product2
                                        WHERE Name IN :productMap.KeySet() and SpecificToCSM__c = true]) {
                                            newProductRef  = productMap.get((productVar.Name).toUpperCase());
                                            if(newProductRef != null)
                                                newProductRef.addError('A similar Product already exist. Cannot create a duplicate product.');
                                        }
        }
        
    }
}