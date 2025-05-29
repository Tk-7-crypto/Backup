import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVideos from '@salesforce/apex/CNT_CSM_EmbedVideo.getVideos';
import updateContentDocumentLinkVisibility from '@salesforce/apex/CNT_CSM_EmbedVideo.updateContentDocumentLinkVisibility';

export default class Lwc_csm_embed_video extends LightningElement {
    @api recordId;
    @track showModal = false;
    @track videoOptions = [];
    selectedVideo = '';
    height = '300';
    width = '400';

    @wire(getVideos, { recordId: '$recordId' })
    wireVideos(result) {
        this.wireVideosResults = result;
        const { error, data } = result;
        if (data) {
            this.videoOptions = [];
            for (let v of data)
                this.videoOptions.push({ label: v.ContentDocument.Title, value: v.ContentDocumentId });
            if (this.videoOptions.length > 0)
                this.selectedVideo = this.videoOptions[0].value;
        } else if (error) {
            console.log(error);
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        for (let index = 0; index < uploadedFiles.length; index++) {
            const contentDocumentId = uploadedFiles[index].documentId;
            updateContentDocumentLinkVisibility({
                linkedEntityId: this.recordId,
                contentDocumentId: contentDocumentId
            }).catch(error => {
                console.log(error);
            });
        }
        let message = '';
        if (uploadedFiles.length === 1) message = uploadedFiles.length + ' video was added.';
        else if (uploadedFiles.length > 1) message = uploadedFiles.length + ' videos were added.';
        this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: message, variant: 'success' }));
        refreshApex(this.wireVideosResults).then((value) => { this.selectedVideo = uploadedFiles[0].documentId; });
    }

    handleVideoListChange(event) {
        this.selectedVideo = event.detail.value;
    }

    handleHeightChange(event) {
        this.height = event.detail.value;
    }

    handleWidthChange(event) {
        this.width = event.detail.value;
    }

    handleEmbedVideo(event) {
        this.showModal = false;
    }


    handleOpenModal(event) {
        this.showModal = true;
    }

    handleCloseModal(event) {
        this.showModal = false;
    }

    handleCopyClick(event) {

        let tag = document.createElement('textarea');
        tag.setAttribute('id', 'copy-me');
        tag.value = this.videoCode;
        document.getElementsByTagName('body')[0].appendChild(tag);
        document.getElementById('copy-me').select();
        document.execCommand('copy');
        document.getElementById('copy-me').remove();

/*
        let copyMe = this.template.querySelector('.copy-me');
        copyMe.select();
        //copyMe.setSelectionRange(0,99999999);
        document.execCommand('copy');
        //navigator.clipboard.writeText(this.videoCode);*/
        this.dispatchEvent(new ShowToastEvent({ message: 'The code has been copied', variant: 'success' }));
    }

    get videoCode() {
        return `[[video controls preload=auto width=${this.width} height=${this.height} src=${this.src} video]]`;
    }

    get src() {
        return `/sfc/servlet.shepherd/document/download/${this.selectedVideo}`;
    }

    get acceptedFormats() {
        return ['.mp4'];
    }

    get hasVideos() {
        return this.videoOptions.length > 0;
    }
}