/**
 * @Author: Neha Bansal(Created on 18 Nov 2016)
 * Description: Test Class for CNT_TPA_Page_Status
**/
@isTest(SeeAllData=false)
public class TST_CNT_TPA_Page_Status {

    public static testMethod void testPageStatusControllerWithPageParameter() {
        //ApexPages.currentPage().getParameters().put('lang', 'English');
        Cookie cookie = new Cookie('lang', 'value', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookie});
        
        TPA_Request__c reqObj = UTL_TPA_SetupTestData.getTestTPARequest();
        insert reqObj;
        reqObj = [Select Id, Name From TPA_Request__c where Id=: reqObj.Id Limit 1];
        ApexPages.currentPage().getParameters().put('reqNo', reqObj.Name);
        CNT_TPA_Page_Status instance = new CNT_TPA_Page_Status();
        String userProfileName = CNT_TPA_Page_Status.currentUserProfileName;
    }

    public static testMethod void testPageStatusControllerWithNoParameter()
    {
        Cookie cookie = null;
        ApexPages.currentPage().setCookies(new Cookie[]{cookie});
        CNT_TPA_Page_Status instance = new CNT_TPA_Page_Status();
    }

    public static testMethod void testPageStatusControllerWithCookieParameter()
    {
        Cookie cookie = new Cookie('lang', 'value', null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookie});
        CNT_TPA_Page_Status instance = new CNT_TPA_Page_Status();
    }
}