/**
 *@Author  : Supriya Johhari
 *@Purpose : 1. Utility class UTL_TPA_AMA Created under ER-3947.
 */
public class UTL_TPA_AMA {
     
     // added by supriya Johari under ER-4020 ends
     private static Set<String> charactersToBeTruncated = new Set<String> {
            ', inc'
            , ',inc'
            , ' inc'
            , ' inc.'
            , ',inc.'
            , ', inc.'
            , ', llc'
            , ',llc'
            , ' llc'
            , ', llp'
            , ',llp'
            , ' llp'
            , ', corp'
            , ',corp'
            , ' corp'
            , ', lp'
            , ',lp'
            , ' lp'
            , ', ltd'
            , ',ltd'
            , ' ltd'
            , ' ltd.'
            , ', ltd.'
            , ',ltd.'
            , ', l.p.'
            , ',l.P.'
            , ' l.p.'
            , ', us'
            , ',us'
            , ' us'
            , ' &co'
            , ' & co'
            , '. co'
            , '.co'
            , ' co.'
            , ' and company'
            , ' pvt'
            , ' pvt.'
        };
    
     public static String getTruncatedValue(String name) {
        String truncatedName = name;
        for(String truncatedCharacters: charactersToBeTruncated) {

            if(truncatedName.endsWithIgnoreCase(truncatedCharacters)) {
                truncatedName = truncatedName.removeEndIgnoreCase(truncatedCharacters).trim();
                truncatedName = truncatedName.removeEnd(',');
                system.debug('truncated name middle ' + truncatedName);
                truncatedName = getTruncatedValue(truncatedName);
            }
        }
        return truncatedName;
    }
    // added by supriya Johari under ER-4020 ends
    
    /**
     * To remove special characters
     */
    public static String getValidStringOnlyWordChar(String inputString) {
        if(String.isNotBlank(inputString)) {
            return String.escapeSingleQuotes(inputString).replaceAll('[^\\w]','');
        }
        return inputString;
    }
    
    // added by supriya Johari under Issue-11508 starts
    /**
     * To provide map for new client vendor match object
     */
    public static Map<String, TPA_AMA_Client_Vendor_Match__c>  getNewClientVendorMatchMap(List<TPA_AMA_Client_Vendor_Match__c> clientVendorMatchList) {
        Map<String, TPA_AMA_Client_Vendor_Match__c> clientVendorMatchMap = new Map<String,TPA_AMA_Client_Vendor_Match__c> ();
        for(TPA_AMA_Client_Vendor_Match__c vendorMatchObj: clientVendorMatchList) {
            clientVendorMatchMap.put(vendorMatchObj.Client_Name__c, vendorMatchObj);
        }
        return clientVendorMatchMap;
    }
    // added by supriya Johari under Issue-11508 ends
}