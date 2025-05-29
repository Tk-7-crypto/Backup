@isTest
public class TST_CNT_TPA_ExternalUserAction { 
	@isTest
    static void CNT_TPA_ExternalUserActionTest1(){
        test.startTest();
        PageReference pageRef = Page.VFP_TPA_ExternalUserAction;
    	Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('actionType' , 'login');
        ApexPages.CurrentPage().getParameters().put('startURL' , '/home');
        ApexPages.CurrentPage().getParameters().put('userName' , 'test@test.com');
        ApexPages.CurrentPage().getParameters().put('userPass' , 'testPassword');
        ApexPages.CurrentPage().getParameters().put('PCSF' , 'test');
        ApexPages.CurrentPage().getParameters().put('CPN' , 'test');
        ApexPages.CurrentPage().getParameters().put('CEACC' , 'test');
        ApexPages.CurrentPage().getParameters().put('VCFN' , 'test');
        ApexPages.CurrentPage().getParameters().put('VCLN' , 'test');
        ApexPages.CurrentPage().getParameters().put('VCTN' , 'test');
        ApexPages.CurrentPage().getParameters().put('VCE' , 'test');
        ApexPages.CurrentPage().getParameters().put('PVSDAV' , 'test');
        ApexPages.CurrentPage().getParameters().put('DASD' , 'test');
        ApexPages.CurrentPage().getParameters().put('DAED' , 'test');
        ApexPages.CurrentPage().getParameters().put('DPSD' , 'test');
        ApexPages.CurrentPage().getParameters().put('DPED' , 'test');
        ApexPages.CurrentPage().getParameters().put('PROV' , 'test');
        ApexPages.CurrentPage().getParameters().put('FOD' , 'test');
        ApexPages.CurrentPage().getParameters().put('FODOT' , 'test');
        CNT_TPA_ExternalUserAction userActionCntrlObj = new CNT_TPA_ExternalUserAction();
        userActionCntrlObj.username = 'test@test.com';
        userActionCntrlObj.password = 'testPassword';
		userActionCntrlObj.extUserAction = 'tpasitelinkaccess';
        userActionCntrlObj.login();
		userActionCntrlObj.extUserAction = 'ExtNewReq';
        userActionCntrlObj.login();
		userActionCntrlObj.extUserAction = 'ExtLogin';
        userActionCntrlObj.login();
        test.stopTest();
    }
}