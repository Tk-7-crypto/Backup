@isTest
public class TST_SLT_Contract_External {
	@isTest
    static void testGetContractUsingContractNumber() {

        Test.startTest();
            List<Contract__x> contractList = new
                SLT_Contract_External().getContractUsingContractNumber('', new Set<String>());
        Test.stopTest();

        system.assertEquals(0, contractList.size(), 'Should return null');
	}

    @isTest
    static void testSelectBidHistoryById() {

        Test.startTest();
            List<Contract__x> contractList = new SLT_Contract_External().selectById(new Set<Id>());
        Test.stopTest();

        system.assertEquals(0, contractList.size(), 'Should return null');
	}
}