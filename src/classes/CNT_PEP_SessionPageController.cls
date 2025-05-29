public class CNT_PEP_SessionPageController {
    public static String fetchUserSessionId(){
        String sSessionId = '';        
        String vfContent;
        try {
            // Get the content of the VF page
            vfContent = Page.VFP_PEP_SessionPage.getContent().toString();
        }catch (VisualforceException e) {
            vfContent = String.valueOf('EDST Some Text EDEY');
        }
        // Find the position of Start and End
        Integer startPosition = vfContent.indexOf('EDST') + 'EDST'.length();
        Integer endPosition = vfContent.indexOf('EDEY');
        // Get the Session Id
        sSessionId = vfContent.substring(startPosition, endPosition);
        // Return Session Id
        return sSessionId;
    }
}