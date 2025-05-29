@isTest
public with sharing class TST_LightningLoginFormController {
    
    @isTest
    static void testLoginWithInvalidCredentials() {
        LightningLoginFormController.login('testUser', 'fakepwd', null);	
        //System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
    }
    
    @isTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @isTest
    static void testIsUsernamePasswordEnabled() {
        LightningLoginFormController.getIsUsernamePasswordEnabled();
        //System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @isTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @isTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @isTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @isTest
    static void testSetExperienceIdWithNull() {
        String experienceId = LightningLoginFormController.setExperienceId(null);
        System.assertEquals(null, experienceId);  
    }
    
    @isTest
    static void testSetExperienceId() {
        String errorMsg = LightningLoginFormController.setExperienceId('xyz');
        System.assertEquals('This method can be invoked only from within a community.', errorMsg);
    }
}