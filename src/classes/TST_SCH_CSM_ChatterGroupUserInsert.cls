@istest
class TST_SCH_CSM_ChatterGroupUserInsert{
    @isTest
	public static void testschedule() {
		Test.StartTest();
		SCH_CSM_ChatterGroupUserInsert testsche = new SCH_CSM_ChatterGroupUserInsert();
		String sch = '0 15 23 08 04 ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}