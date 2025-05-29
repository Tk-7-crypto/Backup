@IsTest
private class TST_SLT_Organization {

    @IsTest
    static void testSelectById(){
        List<Organization> orgList = new SLT_Organization().selectOrganizationList();
        Set<Id> idSet = new Set<Id>();
        for(Organization orgRecord : orgList){
            idSet.add(orgRecord.Id);
        }

        Test.startTest();
        new SLT_Organization().selectById(idSet);
        Test.stopTest();
    }
}