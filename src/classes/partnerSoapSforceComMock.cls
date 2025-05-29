global class partnerSoapSforceComMock implements WebServiceMock {
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if(request instanceOf partnerSoapSforceCom.login_element) {
            new Login().doInvoke(response);
        }
        else if(request instanceOf partnerSoapSforceCom.queryAll_element) {
            new QueryAll().doInvoke(response);
        }
        else if(request instanceOf partnerSoapSforceCom.update_element) {
            new UpdateSobjects().doInvoke(response);
        }
        else if(request instanceOf partnerSoapSforceCom.create_element) {
            new CreateSobjects().doInvoke(response);
        }
    }
    
    public class Login {
        public void doInvoke(Map<String, Object> response) {
            partnerSoapSforceCom.loginResponse_element response_x = new partnerSoapSforceCom.loginResponse_element();
            response_x.result = new partnerSoapSforceCom.LoginResult();
            response.put('response_x', response_x); 
            return;
        }
    }
    
    public class QueryAll {
        public void doInvoke(Map<String, Object> response) {
            partnerSoapSforceCom.queryAllResponse_element response_x = new partnerSoapSforceCom.queryAllResponse_element();
            response_x.result = new partnerSoapSforceCom.QueryResult();
            response.put('response_x', response_x); 
            return;
        }
    }
    
    public class UpdateSobjects {
        public void doInvoke(Map<String, Object> response) {
            partnerSoapSforceCom.updateResponse_element response_x = new partnerSoapSforceCom.updateResponse_element();
            response_x.result = new partnerSoapSforceCom.SaveResult[1];
            response_x.result[0] = new partnerSoapSforceCom.SaveResult();
            response.put('response_x', response_x); 
            return;
        }
    }
    
    public class CreateSobjects {
        public void doInvoke(Map<String, Object> response) {
            partnerSoapSforceCom.createResponse_element response_x = new partnerSoapSforceCom.createResponse_element();
            partnerSoapSforceCom.SaveResult save = new partnerSoapSforceCom.SaveResult();
            save.success = true;
            Blob b = Crypto.generateAESKey(128);
            String h = EncodingUtil.convertToHex(b);
            save.Id = h.substring(0, 18);
            response_x.result = new partnerSoapSforceCom.SaveResult[1];
            response_x.result[0] = save;
            response.put('response_x', response_x); 
            return;
        }
    }
}