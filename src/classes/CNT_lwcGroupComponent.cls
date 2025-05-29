/**
 * @description : Container class for Group which interacts with service class.
 */
public without sharing class CNT_lwcGroupComponent {

    /**
     * method to retrive the list of groups records.
     * @returns : returns the list of groups records.
     */
    @AuraEnabled
    public static list<Group> retriveGroups() {
        return SRV_Group.getGroups();
    }

    /**
     * method to show the buttons as per the user login
     * @returns : Boolean
     */
    @AuraEnabled
    public static Boolean showButtons() {
        return SRV_Group.showButtonsForUser();
    }

    /**
     * method to show the lwcSearchComponent as per the user login
     * @returns : Boolean
     */
    @AuraEnabled
    public static Boolean showAddUserCompoent() {
        return SRV_Group.showLwcSearchComponent();
    }
}