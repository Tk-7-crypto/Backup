@IsTest
private class TST_SLT_PackageLicense {

    @IsTest
    static void testSelectPackageLicensesOnOrg(){
        Test.startTest();
        new SLT_PackageLicense().selectPackageLicensesOnOrg();
        Test.stopTest();
    }
    
    @isTest
    static void testSelectById(){
        List<PackageLicense> packageLicenseList = [SELECT Id, AllowedLicenses, UsedLicenses FROM PackageLicense LIMIT 50];
        Set<Id> idSet = new Set<Id>();
        for(PackageLicense packageRecord : packageLicenseList){
            idSet.add(packageRecord.Id);
        }
        
        Test.startTest();
        new SLT_PackageLicense().selectById(idSet);
        Test.stopTest();
    }

    @IsTest
    static void testSelectPackageMapOnId(){
        List<PackageLicense> packageRecordList = new SLT_PackageLicense().selectPackageLicensesOnOrg();
        Id packageId;
        if(packageRecordList != null && packageRecordList.size() > 0){
            packageId = packageRecordList[0].Id;
        }
        
        Test.startTest();
        new SLT_PackageLicense().selectPackageMapOnId(packageId);
        Test.stopTest();
    }
}