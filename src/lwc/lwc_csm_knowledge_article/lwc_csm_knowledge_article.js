import { LightningElement, api, wire, track } from 'lwc';
import getArtcilesByIdForCurrentUser from '@salesforce/apex/CNT_CSM_CommunityArticleDetail.getArtcilesByIdForCurrentUser';
import addOrRemoveFavorite from '@salesforce/apex/CNT_CSM_AddOrRemoveFavoriteRecord.addOrRemoveFavorite';
import isFavorite from '@salesforce/apex/CNT_CSM_AddOrRemoveFavoriteRecord.isFavorite';
import CLOSE_LABEL from '@salesforce/label/c.Close';
import REMOVE_FROM_BOOKMARKS_LABEL from '@salesforce/label/c.Remove_from_bookmarks';
import ADD_TO_BOOKMARKS_LABEL from '@salesforce/label/c.Add_to_bookmarks';
import BOOKMARKED_LABEL from '@salesforce/label/c.Bookmarked';
import ATTACHMENTS_LABEL from '@salesforce/label/c.Attachments';
import isGuest from "@salesforce/user/isGuest";

export default class Lwc_csm_knowledge_article extends LightningElement {
    labels = {
        Close: CLOSE_LABEL,
        Bookmarked: BOOKMARKED_LABEL,
        Remove_from_bookmarks: REMOVE_FROM_BOOKMARKS_LABEL,
        Add_to_bookmarks: ADD_TO_BOOKMARKS_LABEL,
        Attachments: ATTACHMENTS_LABEL
    };
    @track isLoading = true;
    @track article = '';
    @track isModalOpen = false;
    @track isFavorite = false;
    @api
    set articleId(value) {
        this.isLoading = true;
        this.article = '';
        this._articleId = value;
    }
    get articleId() {
        return this._articleId;
    }
    _articleId;

    @wire(getArtcilesByIdForCurrentUser, { articleId: '$_articleId' })
    wiredArticle({ error, data }) {
        if (data) {
            const article = { ...data };
            this.article = article;
            this.checkFavoriteStatus();
            setTimeout(() => {
                if (this.article.Content__c) {
                    this.article.Content__c = this.article.Content__c.replace(/support\/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Content__c = this.article.Content__c.replace(/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Content__c = this.article.Content__c.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                    this.article.Content__c = this.article.Content__c.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                    this.template.querySelector('[data-id="content"]').innerHTML = this.article.Content__c;
                }
                if (this.article.Question__c) {
                    this.article.Question__c = this.article.Question__c.replace(/support\/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Question__c = this.article.Question__c.replace(/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Question__c = this.article.Question__c.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                    this.article.Question__c = this.article.Question__c.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                    this.template.querySelector('[data-id="question"]').innerHTML = this.article.Question__c;
                }
                if (this.article.Answer__c) {
                    this.article.Answer__c = this.article.Answer__c.replace(/support\/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Answer__c = this.article.Answer__c.replace(/articles\/(\w|\/)*Knowledge\//gi, 'support/s/kb?u=');
                    this.article.Answer__c = this.article.Answer__c.replace(/sfc\/servlet.shepherd/gi, 'support/sfc/servlet.shepherd');
                    this.article.Answer__c = this.article.Answer__c.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
                    this.template.querySelector('[data-id="answer"]').innerHTML = this.article.Answer__c;
                }
            }, 500);
            this.isLoading = false;
        } else if (error) {
            console.error(error);
        }
    }

    get isInformationRecType() {
        return (this.article.RecordTypeId === '0126A000000hC38QAE');
    }

    connectedCallback() {

    }

    checkFavoriteStatus() {
        if (this.article && !this.isGuest) {
            isFavorite({ genericRecord: this.article })
                .then(result => {
                    this.isFavorite = result;
                })
                .catch(error => {
                    console.error('Error checking favorite status:', error);
                });
        }
    }

    toggleFavorite() {
        this.isFavorite = !this.isFavorite;
        if (this.article) {
            addOrRemoveFavorite({
                genericRecord: this.article,
                isFavorite: this.isFavorite
            })
                .then(result => {

                })
                .catch(error => {
                    console.error('Error toggling favorite status:', error);
                });
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    get isGuest() {
        return isGuest;
    }

}
