/*
 * This class provides logic for inbound just-in-time provisioning of single sign-on users while logging in the Salesforce organization.
 * Custom JIT Handler Class.
*/
global class JITHandler implements Auth.SamlJitHandler {
	private class JitException extends Exception{}

    // For new user.
	global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		return null;
	}

    // For updating exisiting users.
	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
            try {
                // Activates users who are eligible for reactivation (Infrequent Users).
                UTL_JITHandler.validateAndActivateUser(userId);                 
            } catch (UTL_JITHandler.CustomJitException ce) {
                // throws the exception message to the SSO login error page URL as a parameter.
                throw new JitException(ce.getMessage());
            } catch (Exception e) {
                UTL_JITHandler.createErrorLog(e.getMessage() + '\n' + e.getStackTraceString(), userId);
                System.debug(e.getMessage());
            } 
    }
}