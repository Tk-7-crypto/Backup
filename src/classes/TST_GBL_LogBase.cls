@isTest
public class TST_GBL_LogBase {
    public static testMethod void testMethod1() {
		new GBL_LogBase.LogFactoryCreator().instance('UTL_LogFactory');
    }
}