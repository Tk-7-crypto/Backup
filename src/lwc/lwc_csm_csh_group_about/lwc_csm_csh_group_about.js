import { LightningElement, api, track, wire } from 'lwc';
import getCollaborationGroupData from '@salesforce/apex/CNT_CSM_CommunityGroups.getGroupDetails';

export default class Lwc_csm_csh_group_about extends LightningElement {
    @api groupId;
    @api productName;
    @track groupName;
    @track fullPhotoUrl;
    @track description;

    connectedCallback() {
        this.loadCollaborationGroupData();
    }

    loadCollaborationGroupData() {
        getCollaborationGroupData({ groupId: this.groupId })
            .then(data => {
                if (data) {
                    this.groupName = data.Name;
                    this.fullPhotoUrl = data.FullPhotoUrl;
                    this.description = data.Description;
                }
            })
            .catch(error => {
                console.error('Error', error);
            });
    }

    navigateToGroup() {
        window.open('group-details?groupId=' + this.groupId, '_blank');
    }
}
