/**
* Name : EXT_TPA_DocusignThankYouScreen
* Author : Babita Dadarwal
* ER : 1940
*/

public class EXT_TPA_DocusignThankYouScreen {
    public string vendorLanguage {get; set;} 
    public string vendorLanguageCode { get; set; }
    
    public EXT_TPA_DocusignThankYouScreen(ApexPages.StandardController stdController) {
        vendorLanguage = ApexPages.currentPage().getParameters().get('language');
        if(vendorLanguage != null && vendorLanguage != '')
            vendorLanguageCode = UTL_TPA_Multilingual.supportedLanguageCodeMap.get(vendorLanguage);
        else
            vendorLanguageCode = 'en';
    }
}