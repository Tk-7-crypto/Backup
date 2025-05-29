global class CNT_TPA_ExternalUserAction {
    global String username {get; set;}
    global String password {get; set;}
    
    public Map<String, String> paramList {
        get {
            if(paramList == null) {
                paramList = ApexPages.currentPage().getParameters();
            }
            return paramList;
        }
        set;
    }
    
    public string extUserAction {get; set;}
    public CNT_TPA_ExternalUserAction() {
        extUserAction = paramList.get('actionType');
    }
    
    global PageReference login() {
        String startUrl = paramList.get('startURL');
        system.debug('startUrl:::'+startUrl);
        //Added for site to community logic submission start
        if(extUserAction == 'tpasitelinkaccess') {
            string usrname = null;
            string usrpass = null;
            string queryString = paramList.get('queyrstring');
            startUrl = '';
            for(String strParamKey: paramList.keyset()) {
                if(strParamKey == 'actionType' || strParamKey == 'startURL' || strParamKey == 'returlpage' || strParamKey == 'userName' || strParamKey == 'userPass') {
                    continue;
                }
                else {
                    startUrl += (strParamKey + '=' + paramList.get(strParamKey) + '&');
                }
            }
            startUrl = startUrl.removeEnd('&');
            system.debug('startUrl0:::'+startUrl);
            if(UTL_TPA.tpaSetting != null) {
                usrname = UTL_TPA.tpaSetting.Vendor_Community_Username__c;
                usrpass = UTL_TPA.tpaSetting.Vendor_Community_Userpass__c;
            }
            if(!String.isEmpty(usrname) && !String.isEmpty(usrpass) && !String.isEmpty(paramList.get('returlpage'))) {
                startUrl = '/imshealthPortal/' + paramList.get('returlpage') + (startUrl != '' ? ('?' + startUrl) : '');
                system.debug('startUrl1:::'+startUrl);
                if(UserInfo.getUserName() == usrname){
                    return new PageReference(startUrl);
                }
                return Site.login(usrname, usrpass, startUrl);
            }
        }
        //Added for site to community logic submission end
        else if(!String.isEmpty(paramList.get('userName')) && !String.isEmpty(paramList.get('userPass'))) {
            String urlWithParams = '';
            if(extUserAction == 'ExtNewReq') {
                urlWithParams += UTL_TPA.requestSubmissionformURL + '?requestType=new&type=c&extAction=ExtNewReq&extPassedValue=';
                if(!String.isEmpty(paramList.get('PCSF'))) {
                    urlWithParams += 'PCSF=' + paramList.get('PCSF') + ':~';
                }
                if(!String.isEmpty(paramList.get('CPN'))) {
                    urlWithParams += 'CPN=' + paramList.get('CPN') + ':~';
                }
                if(!String.isEmpty(paramList.get('CEACC'))) {
                    urlWithParams += 'CEACC=' + paramList.get('CEACC') + ':~';
                }
                if(!String.isEmpty(paramList.get('VCFN'))) {
                    urlWithParams += 'VCFN=' + paramList.get('VCFN') + ':~';
                }
                if(!String.isEmpty(paramList.get('VCLN'))) {
                    urlWithParams += 'VCLN=' + paramList.get('VCLN') + ':~';
                }
                if(!String.isEmpty(paramList.get('VCTN'))) {
                    urlWithParams += 'VCTN=' + paramList.get('VCTN') + ':~';
                }
                if(!String.isEmpty(paramList.get('VCE'))) {
                    urlWithParams += 'VCE=' + paramList.get('VCE') + ':~';
                }
                if(!String.isEmpty(paramList.get('PVSDAV'))) {
                    urlWithParams += 'PVSDAV=' + paramList.get('PVSDAV') + ':~';
                }
                if(!String.isEmpty(paramList.get('DASD'))) {
                    urlWithParams += 'DASD=' + paramList.get('DASD') + ':~';
                }
                if(!String.isEmpty(paramList.get('DAED'))) {
                    urlWithParams += 'DAED=' + paramList.get('DAED') + ':~';
                }
                if(!String.isEmpty(paramList.get('DPSD'))) {
                    urlWithParams += 'DPSD=' + paramList.get('DPSD') + ':~';
                }
                if(!String.isEmpty(paramList.get('DPED'))) {
                    urlWithParams += 'DPED=' + paramList.get('DPED') + ':~';
                }
                if(!String.isEmpty(paramList.get('PROV'))) {
                    urlWithParams += 'PROV=' + paramList.get('PROV') + ':~';
                }
                if(!String.isEmpty(paramList.get('FOD'))) {
                    urlWithParams += 'FOD=' + paramList.get('FOD') + ':~';
                }
                if(!String.isEmpty(paramList.get('FODOT'))) {
                    urlWithParams += 'FODOT=' + paramList.get('FODOT') + ':~';
                }
            }
            else if(extUserAction == 'ExtLogin') {
                urlWithParams += UTL_TPA.tpaSetting.TPA_Client_Community_Url__c + UTL_TPA.customHomePage + '?extAction=ExtLogin';
            }
            system.debug('startUrl:::'+paramList.get('userPass')+'::'+paramList.get('userName')+':::'+paramList.get('extAction'));
            return Site.login(paramList.get('userName'), paramList.get('userPass'), urlWithParams);
        }
        return null;
    }
}