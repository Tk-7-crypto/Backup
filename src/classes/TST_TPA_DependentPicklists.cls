@isTest(seeAllData=false)
public class TST_TPA_DependentPicklists {
    public static testMethod void testTPA_DependentPicklists() {
      TPA_DependentPicklists.GetDependentOptions('tpa_request__c', 'Vendor_Billing_Mailing_Country__c', 'Vendor_Billing_Mailing_State_Province__c');
    }
}