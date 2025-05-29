/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class TST_CommunitiesLoginController {
    @IsTest(SeeAllData=true) 
    global static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }
}