import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserDetails from '@salesforce/apex/CNT_CSM_CommunityPage.getUser';
import WELCOME_LABEL from '@salesforce/label/c.Welcome';
import TO_THE_IQVIA_CUSTOMER_SERVICE_HUB_LABEL from '@salesforce/label/c.to_the_IQVIA_Customer_Service_Hub';
import THE_SITE_DEDICATED_TO_IQVIA_CUSTOMERS_TO_EASILY_FIND_ANSWERS_LABEL from '@salesforce/label/c.The_site_dedicated_to_IQVIA_customers_to_easily_find_answers';
import DOWNLOAD_THE_USER_GUIDE_LABEL from '@salesforce/label/c.Download_The_User_Guide';


export default class Lwc_csm_csh_main_hero extends NavigationMixin(LightningElement) {
    user;
    labels = {
        Welcome: WELCOME_LABEL,
        to_the_IQVIA_Customer_Service_Hub: TO_THE_IQVIA_CUSTOMER_SERVICE_HUB_LABEL,
        The_site_dedicated_to_IQVIA_customers_to_easily_find_answers: THE_SITE_DEDICATED_TO_IQVIA_CUSTOMERS_TO_EASILY_FIND_ANSWERS_LABEL,
        Download_The_User_Guide:DOWNLOAD_THE_USER_GUIDE_LABEL
    };

    @wire(getUserDetails)
    wiredUser({ error, data }) {
        if (data) {
            this.user = data[0];
        } else if (error) {
            console.error('Error retrieving user details:', error);
        }
    }

    get userHasKBAccess() {
        return this.user && this.user.Contact ? !this.user.Contact.Remove_KB_Access__c : true;
    }

    navigateToTheUserGuide(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Resources__c'
            },
            state: {
                p: "IQVIA CUSTOMER SERVICE"
            }
        });
    }

}