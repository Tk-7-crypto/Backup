import { LightningElement, api, track } from 'lwc';
import getCollaborationGroupMemberId from '@salesforce/apex/CNT_CSM_CommunityGroups.getCollaborationGroupMemberId';
import GROUP_ADMINS_LABEL from '@salesforce/label/c.Group_Admins';

export default class Lwc_csm_csh_group_admins_card extends LightningElement {
    @api groupId;
    @track groupMembers;
    @track labels = {
        Group_Admins: GROUP_ADMINS_LABEL
    };

    connectedCallback() {
        this.loadCollaborationGroupMemberId();
    }

    async loadCollaborationGroupMemberId() {
        try {
            const data = await getCollaborationGroupMemberId({ groupId: this.groupId });
            if (data) {
                this.groupMembers = data;
            }
        } catch (error) {
            console.error('Error', error);
        }
    }
}
