import { LightningElement, api, track } from 'lwc';
import getCollaborationGroupData from '@salesforce/apex/CNT_CSM_CommunityGroups.getGroupDetails';
import CLOSE_LABEL from '@salesforce/label/c.Close';
import SHOW_MORE_LABEL from '@salesforce/label/c.Show_More';
import GROUP_INFORMATION_LABEL from '@salesforce/label/c.Group_Information';

const MAX_CHARACTERS = 355;

export default class Lwc_csm_csh_group_information_card extends LightningElement {
    @api groupId;
    @track informationTitle;
    @track informationBody;
    @track trimmedInformationBody;
    @track showMoreButton = false;
    @track showModal = false;
    @track labels = {
        Group_Information: GROUP_INFORMATION_LABEL,
        Show_More: SHOW_MORE_LABEL,
        Close: CLOSE_LABEL
    };

    connectedCallback() {
        this.loadCollaborationGroupData();
    }

    async loadCollaborationGroupData() {
        try {
            const data = await getCollaborationGroupData({ groupId: this.groupId });
            if (data) {
                if (this.informationBody = data.InformationBody) {
                    this.informationBody = data.InformationBody;
                    this.trimmedInformationBody = this.trimBody(this.informationBody);
                }
            }
        } catch (error) {
            console.error('Error', error);
        }
    }

    trimBody(body) {
        let characterCount = 0;
        let trimmedText = '';
        let inTag = false;

        for (let i = 0; i < body.length; i++) {
            const char = body[i];

            if (char === '<') {
                inTag = true;
            } else if (char === '>') {
                inTag = false;
                trimmedText += char;
                continue;
            }

            if (!inTag) {
                characterCount++;
            }

            if (characterCount <= MAX_CHARACTERS) {
                trimmedText += char;
            } else {
                if (!inTag) {
                    break;
                }
            }
        }

        this.showMoreButton = characterCount < body.length;
        trimmedText += '...';
        return trimmedText;
    }

    handleShowMore() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }
}
