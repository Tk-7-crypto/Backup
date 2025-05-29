@isTest(seeAllData = false)
public class TST_SLT_TPAAgreementAdditionalField {
    @isTest
    static void testinstance() {
           SLT_TPAAgreementAdditionalField obj =  SLT_TPAAgreementAdditionalField.instance;
           obj.getSObjectFieldList();
           obj.getSObjectType();
        
    }
}