@isTest(SeeAllData = false)
private class TST_MDM_Defines 
{
	static testMethod void t1()
	{
		system.assert(MDM_Defines.AddressStatus_Map.size() > 0);
	}
}