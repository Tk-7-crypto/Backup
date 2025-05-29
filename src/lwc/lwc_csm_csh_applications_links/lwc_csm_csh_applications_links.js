import { LightningElement, track } from 'lwc';
import getAppLauncherForCurrentUser from '@salesforce/apex/CNT_CSM_AppLauncher.getAppLauncherForCurrentUser';
import APPLAUNCHER_LABEL from '@salesforce/label/c.AppLauncher';

export default class Lwc_csm_csh_applications_links extends LightningElement {
    @track appLinks = [];
    @track isLoading = false;
    @track labels = {
        AppLauncher: APPLAUNCHER_LABEL
    }

    connectedCallback() {
        this.getAppLauncherForCurrentUser();
    }

    getAppLauncherForCurrentUser() {
        this.isLoading = true;
        getAppLauncherForCurrentUser()
            .then(result => {
                this.appLinks = result;
            })
            .catch(error => {
                console.error('Error fetching App Launcher Links:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    navigateToURL(event) {
        const url = event.target.value;
        window.open(url, '_blank');
    }

    get hasAppLinks() {
        return this.appLinks.length > 0;
    }
}
