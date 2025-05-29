@istest
class TST_SCH_CSM_ChatterGroupUserDelete{
    @isTest
	public static void testschedule() {
		Test.StartTest();
		SCH_CSM_ChatterGroupUserDelete testsche = new SCH_CSM_ChatterGroupUserDelete();
		String sch = '0 15 23 08 04 ?';
		system.schedule('Test  delete status Check', sch, testsche );
		Test.stopTest();
	}
}