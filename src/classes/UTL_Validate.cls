/*
 * Version       : 1.0
 * Description   : Apex class class for to custom validation check. 
 */ 
public class UTL_Validate { 
    // Method to check List of sObject is Null or Empty
    public static boolean isEmptyOrNull(List<sObject> lstSObject) {
        return (lstSObject == NULL || lstSObject.isEmpty());
    }
    
    // Method to check Set of sObject is Null or Empty
    public static boolean isEmptyOrNull(Set<sObject> setSObject) {
        return (setSObject == NULL || setSObject.isEmpty());
    }
    
    // Method to check sObject is Null or Empty
    public static boolean isEmptyOrNull(sObject sObj) {
        return sObj == NULL;
    }
    
    // Method to check sObject is Null or Empty
    public static boolean isEmptyOrNull(Object sObj) {
        return sObj == NULL;
    }
    
    // Method to check String is Null or Empty
    public static boolean isEmptyOrNull(String argString) {
        return String.isBlank(argString);
    }
    
    // Method to check Integer value is Null or Empty
    public static boolean isEmptyOrNull(Integer argInteger) {
        return argInteger == NULL;
    }
    
    // Method to check Integer value is Null or Empty
    public static boolean isEmptyOrNull(Decimal argDecimal) {
        return argDecimal == NULL;
    }
    
    // Method to check Boolean value is Null or Empty
    public static boolean isEmptyOrNull(Boolean argBool) {
        return argBool == NULL;
    }
    
    // Method to check Date is Null or Empty
    public static boolean isEmptyOrNull(Date argDate) {
        return argDate == NULL;
    }
    
    // Method to check DateTime is Null or Empty
    public static boolean isEmptyOrNull(DateTime argDateTime) {
        return argDateTime == NULL;
    }
    
    // Method to check if GUID is valid or not
    public static boolean isValidGuid(String guid) {
        String guidRegex = '^(\\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\\}{0,1})$';
        return !isEmptyOrNull(guid) && Pattern.compile(guidRegex).matcher(guid).matches();
    }
    
    // Method to check if future call is allowed or not
    public static boolean isFutureCallAllowed() {
        return (!System.isfuture() && !System.isBatch());
    }
}