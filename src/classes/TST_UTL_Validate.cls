@isTest
public class TST_UTL_Validate { 
    public static testMethod void testMethod1() {
        UTL_Validate.isEmptyOrNull(new List<sObject>());
        UTL_Validate.isEmptyOrNull(new Set<sObject>());
        UTL_Validate.isEmptyOrNull(new Account());
        UTL_Validate.isEmptyOrNull('');
        UTL_Validate.isEmptyOrNull(5);
        UTL_Validate.isEmptyOrNull(0.5);
        UTL_Validate.isEmptyOrNull(true);
        UTL_Validate.isEmptyOrNull(Date.today());
        UTL_Validate.isEmptyOrNull(System.now());
        UTL_Validate.isValidGuid(UTL_Guid.Guid);
        UTL_Validate.isFutureCallAllowed();
    }
}