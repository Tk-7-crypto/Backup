import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import NAME_FIELD from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import REMOVE_KB_ACCESS_FIELD from '@salesforce/schema/Contact.Remove_KB_Access__c';
import REMOVE_CASE_CREATION_FIELD from '@salesforce/schema/Contact.Remove_Case_Creation__c'
import REMOVE_DASHBOARDS_ACCESS_FIELD from '@salesforce/schema/Contact.Remove_Dashboard_Access__c';
import REMOVE_SHARED_FOLDER_ACCESS_FIELD from '@salesforce/schema/Contact.Remove_Shared_Folder_Access__c';
import PORTAL_CASE_TYPE_FIELD from '@salesforce/schema/Contact.Portal_Case_Type__c';
import CONTACT_USER_TYPE_FIELD from '@salesforce/schema/Contact.Contact_User_Type__c';
import CONTACT_ACCOUNT_COUNTRY_FIELD from '@salesforce/schema/Contact.Account.AccountCountry__c';
import isGuest from "@salesforce/user/isGuest";
import KNOWLEDGE_LABEL from '@salesforce/label/c.Knowlegde';
import CASES_LABEL from '@salesforce/label/c.Cases';
import DASHBOARDS_LABEL from '@salesforce/label/c.Dashboards';
import SHARED_FOLDER_LABEL from '@salesforce/label/c.Shared_Folder';
import FORUM_LABEL from '@salesforce/label/c.Forum';
import CREATE_A_NEW_CASE_LABEL from '@salesforce/label/c.Create_a_new_case';
import PROFILE_LABEL from '@salesforce/label/c.Profile';
import ANNOUNCEMENTS_LABEL from '@salesforce/label/c.Announcements';
import SETTINGS_LABEL from '@salesforce/label/c.Settings';
import LOGOUT_LABEL from '@salesforce/label/c.Logout';
import LOGIN_LABEL from '@salesforce/label/c.Login';
import HOME_LABEL from '@salesforce/label/c.Home';

export default class Lwc_csm_csh_menu extends NavigationMixin(LightningElement) {
    @track labels = {
        Knowlegde: KNOWLEDGE_LABEL,
        Cases: CASES_LABEL,
        Dashboards: DASHBOARDS_LABEL,
        Shared_Folder: SHARED_FOLDER_LABEL,
        Forum: FORUM_LABEL,
        Create_a_new_case: CREATE_A_NEW_CASE_LABEL,
        Profile: PROFILE_LABEL,
        Settings: SETTINGS_LABEL,
        Announcements: ANNOUNCEMENTS_LABEL,
        Logout: LOGOUT_LABEL,
        Login: LOGIN_LABEL,
        Home: HOME_LABEL
    };
    profilesWithAccessToGroups = ['Service User', 'System Administrator', 'System Administrator Module', 'System Administrator Package Support', 'System Administrator Integration', 'IQVIA Salesforce Platform Support'];
    @track isMenuOpen = false;
    @track isSearchOpen = false;
    @track currentUserId = USER_ID;
    @track userContactId;
    @track currentPageName;

    renderedCallback() {
        if (this.currentPageName) {
            this.setActiveMenuItem();
        }
    }

    setActiveMenuItem() {
        const pageName = this.currentPageName.includes('Group') ? 'Groups__c' : this.currentPageName;
        const selectedItemLink = this.template.querySelector(`[data-name='${pageName}']`);
        if (selectedItemLink) {
            const menuItems = this.template.querySelectorAll('.slds-context-bar__item');
            menuItems.forEach(item => {
                item.classList.remove('slds-is-active');
            });

            const selectedItem = selectedItemLink.closest('.slds-context-bar__item');
            if (selectedItem) {
                selectedItem.classList.add('slds-is-active');
            }
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(value) {
        if (value && value.attributes) {
            if(value.attributes.name){
               this.currentPageName = value.attributes.name;
            }else if(value.attributes.actionName){
                this.currentPageName = value.attributes.actionName;
            }
            this.setActiveMenuItem();
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, CONTACT_ID_FIELD, PROFILE_NAME_FIELD] })
    user;

    @wire(getRecord, { recordId: '$user.data.fields.ContactId.value', fields: [CONTACT_ACCOUNT_COUNTRY_FIELD, REMOVE_KB_ACCESS_FIELD, REMOVE_CASE_CREATION_FIELD, REMOVE_DASHBOARDS_ACCESS_FIELD, REMOVE_SHARED_FOLDER_ACCESS_FIELD, PORTAL_CASE_TYPE_FIELD, CONTACT_USER_TYPE_FIELD] })
    userContact;

    get userName() {
        return this.user && this.user.data ? getFieldValue(this.user.data, NAME_FIELD) : '';
    }

    get userContactId() {
        return this.user && this.user.data ? getFieldValue(this.user.data, CONTACT_ID_FIELD) : '';
    }

    get userHasAccessToGroups() {
        const profileName = this.user && this.user.data ? getFieldValue(this.user.data, PROFILE_NAME_FIELD) : '';
        return this.profilesWithAccessToGroups.includes(profileName);
    }

    get userHasKBAccess() {
        return this.userContact && this.userContact.data ? !getFieldValue(this.userContact.data, REMOVE_KB_ACCESS_FIELD) : true;
    }

    get userHasAccessToCases() {
        return true;
        this.userContact && this.userContact.data
            ? getFieldValue(this.userContact.data, PORTAL_CASE_TYPE_FIELD) !== 'R&D'
            : true;
    }

    get userHasAccessToSharedFolder() {
        if (this.userContact && this.userContact.data) {
            const removeSharedFolderAccess = getFieldValue(this.userContact.data, REMOVE_SHARED_FOLDER_ACCESS_FIELD);
            return !(removeSharedFolderAccess === true);
        }
        return true;
    }

    get userHasAccessToDashboards() {
        if (this.userContact && this.userContact.data) {
            const removeDashboardAccess = getFieldValue(this.userContact.data, REMOVE_DASHBOARDS_ACCESS_FIELD);
            return !(removeDashboardAccess === true);
        }
        return true;
    }

    get userHasCaseCreation() {
        if (this.userContact && this.userContact.data) {
            const removeCaseCreation = getFieldValue(this.userContact.data, REMOVE_CASE_CREATION_FIELD);
            return !(removeCaseCreation === true);
        }
        return true;
    }

    get userHasAccessToForum() {
        if (this.userContact && this.userContact.data) {
            const accountCountry = getFieldValue(this.userContact.data, CONTACT_ACCOUNT_COUNTRY_FIELD);
            const portalCaseType = getFieldValue(this.userContact.data, PORTAL_CASE_TYPE_FIELD);
            if (portalCaseType === 'R&D' || (portalCaseType === 'Information Offering' && accountCountry === 'DE')) {
                return false;
            }
        }
        return true;
    }

    openSearch() {
        this.isSearchOpen = true;
    }

    closeSearch() {
        this.isSearchOpen = false;
    }

    toggleMenu() {
        this.isMenuOpen = !this.isMenuOpen;
    }

    handleNavigation(event) {
        const pageName = event.target.value !== null && event.target.value !== undefined ? event.target.value : event.target.closest('a').dataset.name;
        if (pageName) {
            const url = new URL(document.URL);
            const newUrl = url.origin + url.pathname;
            window.history.pushState({ path: newUrl }, '', newUrl);

            const state = {};
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageName
                },
                state
            });

            if (this.isMenuOpen) {
                this.toggleMenu();
            }
        }
    }

    handleProfileMenuSelect(event) {
        const selectedValue = event.detail.value;
        const state = {};
        if (selectedValue === 'Logout') {
            const baseUrl = window.location.origin;
            const communityUrl = baseUrl + '/support';
            const logoutUrl = `${communityUrl}/secur/logout.jsp?retUrl=${communityUrl}`;
            window.location.href = logoutUrl;
        } else if (selectedValue === 'Settings') {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/settings/' + this.currentUserId
                }
            });
        } else if (selectedValue === 'Profile') {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/profile/' + this.currentUserId
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: selectedValue
                },
                state
            });
        }

        const menuItems = this.template.querySelectorAll('.slds-context-bar__item');
        menuItems.forEach(item => {
            item.classList.remove('slds-is-active');
        });
    }

    get menuClasses() {
        return `slds-grid menu ${this.isMenuOpen ? 'open' : ''}`;
    }

    get isGuest() {
        return isGuest;
    }
}
