@isTest
public class TST_SLT_UserLicense {
    static testmethod void test1(){
        new SLT_UserLicense().fetchLicenseUsingName(new Set<String>{'Id','Name'}, new Set<String>{CON_CRM.SALESFORCE_LICENSE});
    }
}