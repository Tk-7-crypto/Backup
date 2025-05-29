/**
 * Version : 1.0
 * An apex class that exposes response of the lookup result.
 */
public with sharing class Lookup_ResponseData {
    public Boolean isSuccess;
    public Map<String, Object> results;
    public String errMsg;

    public Lookup_ResponseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public void addError(String errMsg){
        this.errMsg = errMsg;
        this.isSuccess = false;
    }

    public String getJsonString() {
        return UTL_Lookup.serializeWithoutNamespace(this);
    }
}