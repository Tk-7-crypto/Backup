import { LightningElement, track, api } from 'lwc';
import getFavorites from '@salesforce/apex/CNT_CSM_CommunityFavorites.getFavorites';
import BOOKMARKS_LABEL from '@salesforce/label/c.Bookmarks';
import DOCUMENTATION_LABEL from '@salesforce/label/c.Documentation';
import CASES_LABEL from '@salesforce/label/c.Cases';
export default class Lwc_csm_csh_bookmarks extends LightningElement {
    @api showTitle = false;
    @track articles = [];
    @track cases = [];
    @track labels = {
        Bookmarks: BOOKMARKS_LABEL,
        Documentation: DOCUMENTATION_LABEL,
        Cases: CASES_LABEL
    };

    connectedCallback() {
        this.getFavorites();
    }

    getFavorites() {
        getFavorites()
            .then(result => {
                let favorites = result;
                this.articles = favorites.filter(fav => fav.entityName === 'Knowledge__kav').map(article => {
                    return { ...article, url: '/support/s/kb?u=' + article.urlName };
                });
                this.cases = favorites.filter(fav => fav.entityName === 'Case').map(c => {
                    return { ...c, url: '/support/s/case/' + c.entityId };
                });
                this.articles.sort((a, b) => (a.title > b.title) ? 1 : ((b.title > a.title) ? -1 : 0));

            })
            .catch(error => {
                console.error('Error', error);
            });
    }

    get hasFavorites() {
        return this.articles.length > 0 || this.cases.length > 0;
    }
}