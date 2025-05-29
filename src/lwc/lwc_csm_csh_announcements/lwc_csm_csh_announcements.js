import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAnnouncements from '@salesforce/apex/CNT_CSM_Announcements.getAnnouncementsForCurrentUser';
import TIMEZONE from '@salesforce/i18n/timeZone';
import ANNOUNCEMENTS_LABEL from '@salesforce/label/c.Announcements';
import SEE_ALL_ANNOUNCEMENTS_LABEL from '@salesforce/label/c.See_all_announcements';
import CLOSE_LABEL from '@salesforce/label/c.Close';

export default class Lwc_csm_csh_announcements extends NavigationMixin(LightningElement) {
    @api includeExpired = false;
    @track labels = {
        Announcements: ANNOUNCEMENTS_LABEL,
        See_all_announcements: SEE_ALL_ANNOUNCEMENTS_LABEL,
        Close: CLOSE_LABEL
    };
    @track announcements = [];
    msgNoAnnouncement = ''
    timezone = TIMEZONE;
    @track isModalOpen = false;
    @track isLoading = true;
    @track selectedAnnouncement;

    connectedCallback() {
        this.getAnnouncements();
    }
    getAnnouncements() {
        getAnnouncements({ includeExpired: this.includeExpired })
            .then(result => {
                this.announcements = Array.isArray(result) ? result.slice() : [];
                if (this.announcements.length > 0) {
                    this.announcements.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
                    this.announcements.forEach((announcement, index) => {
                        let updatedAnnouncement = { ...announcement };
                        updatedAnnouncement.isExpired = new Date(updatedAnnouncement.Expiry_Date__c) < new Date();
                        this.announcements[index] = updatedAnnouncement;
                    });
                } else {
                    this.msgNoAnnouncement = 'No announcements found';
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching announcements for current user', error);
            });
            this.isLoading = false;
    }
    
    get hasAnnouncements() {
        return this.announcements.length > 0 ;
    }

    navigateToAnnouncements(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Announcements2__c'
            }
        });
    }

    handleAnnouncementClick(event) {
        const announcementId = event.currentTarget.dataset.key;
        this.selectedAnnouncement = this.announcements.find(announcement => announcement.Id === announcementId);
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
}