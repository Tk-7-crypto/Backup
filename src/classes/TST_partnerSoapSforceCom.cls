@isTest
public class TST_partnerSoapSforceCom {
    
    testmethod static void loginTest() {
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        partnerSoapSforceCom.Soap atPartnerSoap = new partnerSoapSforceCom.Soap();
        partnerSoapSforceCom.GetUserInfoResult userInfo = new partnerSoapSforceCom.GetUserInfoResult();
        String username = 'abc@metacube.com';
        String password = '12345896';
        atPartnerSoap.login(username, password);
        Test.stopTest();
    }
    
    testmethod static void queryAllTest() {
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        partnerSoapSforceCom.Soap atPartnerSoap = new partnerSoapSforceCom.Soap();
        atPartnerSoap.queryAll('SELECT Id from Account');
        Test.stopTest();
    }
    
    testmethod static void updateTest() {
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        partnerSoapSforceCom.Soap atPartnerSoap = new partnerSoapSforceCom.Soap();
        atPartnerSoap.update_x(null);
        Test.stopTest();
    }

}