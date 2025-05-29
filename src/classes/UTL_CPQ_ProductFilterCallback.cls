public class UTL_CPQ_ProductFilterCallback {
    
    public static String productsExcludeForDPS(String licenceType, String documentType) {
        String retunString = 'NOT (Apttus_Config2__ComponentProductId__r.ProductCode IN (\'';
        if (licenceType == CON_CPQ.PER_STUDY) {
            for (String optionProduct : CON_CPQ.EXCLUDE_ENTERPRISE_OPTION_PRODUCTS) {
                retunString += optionProduct + '\', \''; 
            }
        } else {
            for (String optionProduct : CON_CPQ.EXCLUDE_PER_STUDY_OPTION_PRODUCTS) {
                retunString += optionProduct + '\', \''; 
            }  
        }
        Set<String> productCodes = new Set<String>{'CES_2077M', 'CES_2077E', 'CES_2077K', 'CES_2077L', 'CES_2077A'};
        if (documentType == CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS) {
            productCodes.remove('CES_2077L');
        } else if (documentType ==  CON_CPQ.PDF_DOCUMENT_BUNDLES) {
            productCodes.remove('CES_2077M');
        } else if (documentType == CON_CPQ.INTERACTIVE_INDIVIDUAL_DOCUMENT) {
            productCodes.remove('CES_2077E');
            productCodes.remove('CES_2077A');
        } else if (documentType == CON_CPQ.INTERACTIVE_DOCUMENT_BUNDLE) {
            productCodes.remove('CES_2077K');
        }
      
        if (!productCodes.isEmpty()) {
            retunString += String.join(productCodes, '\', \'') + '\', \'';
        }
        retunString = retunString.substring(0, retunString.length()-3) + '))';
        return retunString;
    }
}