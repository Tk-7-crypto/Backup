//Updated by Babita Dadarwal under ER-2692 Start
public without sharing class TPA_CommunitiesLandingController {
    public static string communityUrl
    {
        get
        {
            return UTL_TPA.TPA_COMMUNIYTURL;
        }
        set;
    }

    String requestSubmissionformURL = UTL_TPA.requestSubmissionformURL;

    //Added for site to community logic submission start
    public static Boolean isVendorUser {
        get {
            if(UTL_TPA.getVendorProfileMap().get(userinfo.getProfileid()) != null 
               && UTL_TPA.getVendorProfileMap().get(userinfo.getProfileid()).Name == 'TPA Vendor Community User') {
                return true;
            }
            return false;
        }
        set;
    }
    //Added for site to community logic submission end

    // Code we will invoke on page load.
    public PageReference forwardToStartPage()
    {

        if(isVendorUser) {
            return new PageReference(communityUrl + '/VFP_TPA_CustomLandingPage');
        }
        
        communityUrl = UTL_TPA.TPA_COMMUNIYTURL;
        String customHomePage = '/VFP_TPA_PrivacyNotice';
        String actionType = ApexPages.currentPage().getParameters().get('actionType');

        //User currentCommUser = [select id, TPA_Is_Privacy_Policy_Agreed__c from user where id =: UserInfo.getUserId()];
        User currentCommUser = UTL_TPA.getCurrentUserDetails();

        system.debug('Inside Community page '+currentCommUser );

        if (UserInfo.getUserType().equals('Guest'))
        {
            system.debug('Inside guest user :::'+actionType);
            return new PageReference(UTL_TPA.cshCommunityLoginURL);
            //return new PageReference(communityUrl + '/login');
            /*if(actionType == 'login')
                return new PageReference(communityUrl + '/login');
            else
                return null;*/
        }
        else if (currentCommUser != NULL && currentCommUser.TPA_Is_Privacy_Policy_Agreed__c== true )
        {
            system.debug('Inside Community if TPA_Is_Privacy_Policy_Agreed__c is true ');
            //return new PageReference(communityUrl + '/login?startURL=' +
            //EncodingUtil.urlEncode(customHomePage, 'UTF-8'));
            //Added by Babita on 7 april 2015 under ER-1784 Start
            currentCommUser.TPA_Is_Show_TPA_Down_Message__c = false;
            update currentCommUser;
            //Added by Babita on 7 april 2015 under ER-1784 End

            //Added by C.P.Pandey under ER-3296 start
            /*Cookie ckExtUsrAction = ApexPages.currentPage().getCookies().get('extUserActionVal');
            system.debug('ckExtUsrAction0:::'+ckExtUsrAction);
            Map<string, string> usrActionParamMap = new Map<string, string>();
            if(ckExtUsrAction != null && !String.isEmpty(ckExtUsrAction.getValue()))
            {system.debug('ckExtUsrAction:::'+ckExtUsrAction.getValue());
                string extPassedValue = '';
                for(string parObj: ckExtUsrAction.getValue().split('&'))
                {
                    if((parObj.split('=')).size() == 2)
                    {
                        usrActionParamMap.put(parObj.split('=')[0], parObj.split('=')[1]);
                        if(parObj.split('=')[0] != 'userName' && parObj.split('=')[0] != 'userPass')
                            extPassedValue += (parObj + ':~');
                    }
                }
                if(usrActionParamMap.get('extAction') == 'ExtNewReq')
                {
                    ApexPages.currentPage().setCookies(new System.Cookie[] { new System.Cookie('extUserActionVal', null, null, 0, false) });
                    ApexPages.currentPage().getCookies().put('extUserActionVal', null);
                    ckExtUsrAction = null;
                    return new PageReference(requestSubmissionformURL + '?requestType=new&type=c&extAction=ExtNewReq&extPassedValue='+extPassedValue);
                }
            }
            if(usrActionParamMap.get('extAction') != 'ExtLogin')
            {
                ApexPages.currentPage().setCookies(new System.Cookie[] { new System.Cookie('extUserActionVal', null, null, 0, false) });
                ApexPages.currentPage().getCookies().put('extUserActionVal', null);
                ckExtUsrAction = null;
            }*/
            //Added by C.P.Pandey under ER-3296 end
            return new PageReference(communityUrl + '/VFP_TPA_CustomLandingPage'); //Modified by C.P.Paney under ER-1940
            //Schema.DescribeSObjectResult tpaSObjectSchema = TPA_Request__c.SObjectType.getDescribe();
            //String objectIdPrefix = tpaSObjectSchema.getKeyPrefix();
            //return new PageReference(communityUrl + '/' + objectIdPrefix + '/o');

        }
        else if(currentCommUser != NULL && currentCommUser.TPA_Is_Privacy_Policy_Agreed__c== false)
        {
            system.debug('Inside Community if TPA_Is_Privacy_Policy_Agreed__c is false ');
            return new PageReference(communityUrl + customHomePage);
        }
        return new PageReference(communityUrl + '/login');
        // return Network.communitiesLanding();
    }

    @remoteAction
    public static String sendUserName(String companyEmail)
    {
        String returnResult = '';
        companyEmail = (String)JSON.deserialize(companyEmail, String.class);

        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();

        contactList = [select id, Name from Contact where Email =: companyEmail and (recordtype.name = 'Contact')];

        system.debug('Contact List =  ' + contactList);

        String bodyText = '';
        String tpaAdminEmail = '';

        TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
        if(tpaSetting != null && tpaSetting.TPA_Admin_Email_Address__c != null)
        {
            tpaAdminEmail = tpaSetting.TPA_Admin_Email_Address__c;

        }
        //Updated by Babita Dadarwal under Issue-09246 on 4 Aug 2016 start
        if(contactList.size() > 0)
        {
            if(contactList.size() == 1)
            {
                userList = [select id, name, Email, Username, IsActive from User where Contact.Id =: contactList[0].Id];

                if(userList.size() > 0)
                {
                    if(userList[0].IsActive)
                    {
                        bodyText = '';
                        bodytext += '<br>Your  user name for the '+Label.TPA_IQVIA_Keyword+' Third Party Program is provided below:';
                        bodytext += '<br><br><center>' + userList[0].Username + '</center>';
                        bodytext += '<br><br>Click here to sign onto the <a href="' + communityUrl + '/login">'+Label.TPA_IQVIA_Keyword+' Third Party Program Portal </a>';
                        bodytext += '<br><br>If you forgot your password, you can reset it using the user name provided above and the "Forgot  Your Password? " Link on the log-in page';
                        bodytext += '<br><br>If you did not request your user name to be sent please contact the '+Label.TPA_IQVIA_Keyword+' Third Party Program at IQVIATPProgram@iqvia.com ';

                        sendUsernameMail(companyEmail, bodytext);

                        returnResult = 'success'+ '1 contact ' + userList[0].Username +'Active user -- 1st condtion';
                        //return 'success'+ '1 contact ' + userList[0].Username +'Active user -- 1st condtion';
                    }
                    else
                    {
                        bodyText = '';
                        bodytext += '<br>User is in active for the given email address \'' + companyEmail + '\'';

                        sendUsernameMail(tpaAdminEmail, bodytext);
                        //sendUsernameMail('SKumari@us.imshealth.com', bodytext);

                        returnResult = 'success'+ '1 contact ' + userList[0].Username +'In Active user --sent a mail to tpa admin -- 1st condtion';
                        //return 'success'+ '1 contact ' + userList[0].Username +'In Active user --sent a mail to tpa admin -- 1st condtion';
                    }
                }
                else
                {
                    bodyText = '';
                    bodytext += '<br>The email address provided did not have an '+Label.TPA_IQVIA_Keyword+' Third Party Program portal user name assigned. ';
                    bodytext += '<br><br>Please contact your '+Label.TPA_IQVIA_Keyword+' Account team to be provided a User name and password for entry into the '+Label.TPA_IQVIA_Keyword+' Third Party Program portal.';
                    bodytext += '<br><br>If you did not request your user name to be sent please contact the '+Label.TPA_IQVIA_Keyword+' Third Party Program at IQVIATPProgram@iqvia.com ';

                    sendUsernameMail(companyEmail, bodytext);

                    returnResult = 'success'+ '1 contact  no user 2nd condtion';
                    //return 'success'+ '1 contact  no user 2nd condtion';
                }
            }
            else
            {
                bodyText = '';

                bodytext += '<br>There are multiple usernames exist for the given email address \'' + companyEmail + '\'';
                bodytext += '<br><br>Please check and send the correct username to the user.';

                sendUsernameMail(tpaAdminEmail, bodytext);

                returnResult = 'success'+ 'more than one contact -- Tpa Admin case  ' + companyEmail + contactList.size() +  'User size   ' + userList.size();
                //return 'success'+ 'more than one contact -- Tpa Admin case  ' + companyEmail + contactList.size() +  'User size   ' + userList.size();
            }

        }
        else
        {
            bodytext += '<br>The email address provided has not yet  been registered at '+Label.TPA_IQVIA_Keyword+'.';
            bodytext += '<br><br>Please contact your '+Label.TPA_IQVIA_Keyword+' Account team to be provided a User name and password for entry into the '+Label.TPA_IQVIA_Keyword+' Third Party Program portal. ';
            bodytext += '<br><br>If you did not request your username to be sent please contact the '+Label.TPA_IQVIA_Keyword+' Third Party Program at IQVIATPProgram@iqvia.com ';

            sendUsernameMail(companyEmail, bodytext);

            returnResult = 'success'+ 'No COntact 3rd condtion' + companyEmail + contactList.size() +  'User size   ' + userList.size();
            //return 'success'+ 'No COntact 3rd condtion' + companyEmail + contactList.size() +  'User size   ' + userList.size();
        }
        //Updated by Babita Dadarwal under Issue-09246 on 4 Aug 2016 End
        if(returnResult == '') {
            returnResult = 'fail' + companyEmail;
        }
        return returnResult;
    }

    public static void sendUsernameMail(String companyEmail, String bodyText)
    {
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String orgWideMailId = TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c;
        String subjText = Label.TPA_IQVIA_Keyword+' Third Party Program Request for User Name';
     //   List<String> strList = new List<String>(); //commented by neha starts under Issue 9062

        //strList.add(companyEmail);  //commented by neha starts under Issue 9062

        /**********DO NOT MIGRATE*********/
        /* Commented by neha Starts 9062
         * List<String> ccAddress = new List<String>();
        ccAddress.add('babita.dadarwal@metacube.com');
        mail.setCcAddresses(ccAddress); Commented by neha Ends 9062*/
        /**********DO NOT MIGRATE*********/

        //added by neha starts under Issue 9062
        String[] address;
        String emailaddresses = TPA_Settings__c.getInstance().TPA_Forgot_UserName_Email__c;
        if(emailaddresses !=NULL && emailaddresses.trim() != '')
        {
             address = emailaddresses.split(',', 0);
             mail.setCcAddresses(address);
        }

        String[] strList;
        if(companyEmail != NULL && companyEmail.trim() != '')
        {
            strList = companyEmail.split(',', 0);
        }


        //added by neha Ends Under Issue 9062

        mail.setSubject(subjText);
        mail.setToAddresses(strList);
        mail.setHtmlBody(bodyText);

        if(orgWideMailId != null)
            mail.setOrgWideEmailAddressId(orgWideMailId);
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest())
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('Mail Sent');
            }
        }
        catch(Exception e)
        { 
             System.debug('Email Failed: ' + e.getMessage());
        }

    }
}
//Updated by Babita Dadrwal under ER-2692 end