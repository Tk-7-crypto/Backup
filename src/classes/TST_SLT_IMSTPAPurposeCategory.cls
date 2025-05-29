@isTest(seeAllData = false)
public class TST_SLT_IMSTPAPurposeCategory {
    @isTest
    static void testselectAllActiveIMSTPAPurposeCategory() {
        Set<String> fieldSet = new Set<String> {'IMS_TPA_Purpose__r.Primary_Purpose_Name__c'};
            SLT_IMSTPAPurposeCategory.instance.selectAllActiveIMSTPAPurposeCategory(fieldSet, 'IMS_TPA_Purpose__r.Primary_Purpose_Name__c', 'asc');
    }
    
}