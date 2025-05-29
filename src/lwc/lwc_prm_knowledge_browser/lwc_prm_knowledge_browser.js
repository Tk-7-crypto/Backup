import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getKnowledgeArticles from '@salesforce/apex/CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentPRMUser';
import getFavoriteArticles from '@salesforce/apex/CNT_CSM_CommunityArticles.getFavoriteArticles';
import getArticleProductByUrlName from '@salesforce/apex/CNT_CSM_CommunityArticles.getArticleProductByUrlName';
import getProductTopics from '@salesforce/apex/CNT_CSM_CommunityTopics.getProductCommunityTopics';
import FILTER_BY_PRODUCT_LABEL from '@salesforce/label/c.Filter_by_product';
import FILTER_BY_CHAPTER_LABEL from '@salesforce/label/c.Filter_by_chapter';
import FILTER_BY_TITLE_LABEL from '@salesforce/label/c.Filter_by_title';
import MORE_FILTERS_LABEL from '@salesforce/label/c.More_filters';
import NEW_ARTICLE_LABEL from '@salesforce/label/c.New_Article';
import UPDATED_ARTICLE_LABEL from '@salesforce/label/c.Updated_Article';
import FOR_MY_ACCOUNT_LABEL from '@salesforce/label/c.For_my_account';
import BOOKMARKED_ARTICLE_LABEL from '@salesforce/label/c.Bookmarked_Article';
import NO_ARTICLE_FOUND_FOR_THIS_PRODUCT_LABEL from '@salesforce/label/c.No_articles_found_for_this_product';
import ALL_CHAPTERS_LABEL from '@salesforce/label/c.All_chapters';
import SEE_FILES_LABEL from '@salesforce/label/c.See_files';
import USER_LANGUAGE from '@salesforce/i18n/lang';

export default class lwc_prm_knowledge_browser extends NavigationMixin(LightningElement) {
    labels = {
        Filter_by_product: FILTER_BY_PRODUCT_LABEL,
        Filter_by_chapter: FILTER_BY_CHAPTER_LABEL,
        Filter_by_title: FILTER_BY_TITLE_LABEL,
        More_filters: MORE_FILTERS_LABEL,
        New_article: NEW_ARTICLE_LABEL,
        Updated_article: UPDATED_ARTICLE_LABEL,
        For_my_account: FOR_MY_ACCOUNT_LABEL,
        Bookmarked_article: BOOKMARKED_ARTICLE_LABEL,
        No_articles_found_for_this_product: NO_ARTICLE_FOUND_FOR_THIS_PRODUCT_LABEL,
        All_chapters: ALL_CHAPTERS_LABEL,
        See_files: SEE_FILES_LABEL

    };
    @track isLoading = true;
    @track treeItems = [];
    @track filteredTreeItems = [];
    @track forThisAccFilter = false;
    @track isNew = false;
    @track isUpdated = false;
    @track isFavorite = false;
    @track favoriteArticles = [];
    selected = '';
    @track selectedArticle = '';
    @track titleFilter = '';
    chapters = [];
    selectedChapter = '';
    @track chapterOptions = [];
    products = [];
    @api
    set selectedProduct(value) {
        if (value && value.trim() !== '' && value != this._selectedProduct) {
            this._selectedProduct = value;
            this.fetchArticles();
        } else if (!value || value.trim() === '') {
            this._selectedProduct = '';
        }
        this.productSelectedEvent();
    }
    get selectedProduct() {
        return this._selectedProduct;
    }
    _selectedProduct = '';
    @track productOptions = [];
    selectedArticleUrlName = '';
    @track panelOpen = true;
    @track language = 'en_US'

    connectedCallback() {
        const currentUrl = new URL(window.location.href);
        const urlSearchParams = new URLSearchParams(currentUrl.search);
        if (urlSearchParams.has('p') && urlSearchParams.has('u')) {
            urlSearchParams.delete('u');
            const newUrl = `${currentUrl.origin}${currentUrl.pathname}?${urlSearchParams.toString()}`;
            window.history.replaceState({}, '', newUrl);
        } else if (urlSearchParams.has('u')) {
            const articleUrlName = currentUrl.searchParams.get('u');
            if (articleUrlName) {
                this.selectedArticleUrlName = articleUrlName;
                this.getArticleProductByUrlName(this.selectedArticleUrlName);
            }
        }
    }

    @wire(getProductTopics)
    wiredProductTopics({ error, data }) {
        if (data) {
            this.products = data.map((item) => ({
                label: item.Name,
                value: item.Name,
            }));
            this.productOptions = this.products;
            const url = new URL(document.URL);
            const productName = url.searchParams.get('p');
            if (productName) {
                const index = this.productOptions.findIndex(
                    (item) => item.value === productName
                );
                if (index !== -1) {
                    this.selectedProduct = this.productOptions[index].value;
                    const url = new URL(document.URL);
                    const newUrl = url.toString();
                    document.title = 'Docs for ' + this.selectedProduct;
                    window.history.replaceState({ path: newUrl }, '', newUrl);
                } else {
                    urlParams.delete('p');
                    const newUrl = `${window.location.pathname}?${urlParams.toString()}${window.location.hash}`;
                    window.history.replaceState(null, '', newUrl);
                }
            }
        } else if (error) {
            console.error(error);
        }
        this.isLoading = false;
    }



    @wire(getFavoriteArticles)
    wiredFavoriteArticles({ error, data }) {
        if (data) {
            this.favoriteArticles = data;
        } else if (error) {
            console.error(error);
        }
    }

    getLanguage() {
        const lang = USER_LANGUAGE;
        this.language = lang.replace('-', '_');
        console.log('lang', this.language);
        return this.language;
    }

    fetchArticles() {
        this.isLoading = true;
        getKnowledgeArticles({
            category: this.selectedProduct,
            language: this.getLanguage()
        })
            .then(result => {
                const chapters = new Map();
                const today = new Date().toISOString().slice(0, 10);
                result.forEach(article => {
                    const contentArticle = article.contentArticle;
                    let chapterLabel = this.decodeHtmlEntities(contentArticle.Article_Chapter__c);

                    if (!chapters.has(chapterLabel)) {
                        chapters.set(chapterLabel, []);
                    }

                    const isEndDisplayDateInFuture = contentArticle.End_date_of_display_as_new_or_updated__c >= today;
                    const isFirstVersion = contentArticle.VersionNumber === 1;
                    const isNew = isEndDisplayDateInFuture && isFirstVersion;
                    const isUpdated = isEndDisplayDateInFuture && !isFirstVersion;
                    const isFavorite = this.favoriteArticles.some(fav => fav.EntityId__c === contentArticle.KnowledgeArticleId);

                    chapters.get(chapterLabel).push({
                        label: contentArticle.Title,
                        urlName: contentArticle.UrlName,
                        id: contentArticle.Id,
                        product: contentArticle.ProductName__c,
                        topic: contentArticle.Product__r.Community_Topic__r.Name,
                        chapter: chapterLabel,
                        forThisAcc: article.forThisAcc,
                        isNew: isNew,
                        isUpdated: isUpdated,
                        isFavorite: isFavorite,
                        selected: false,
                        articleTotalViewCount: contentArticle.ArticleTotalViewCount,
                        chapterOrder: article.chapterOrder,
                        articleOrder: article.articleOrder
                    });

                });

                this.treeItems = [...chapters.entries()]
                    .sort((a, b) => a[1][0].chapterOrder - b[1][0].chapterOrder)
                    .map(([label, items]) => {
                        items.sort((a, b) => a.articleOrder - b.articleOrder);
                        return {
                            label,
                            expanded: true,
                            items
                        };
                    });

                if (this.selectedArticle === '') {
                    if (this.selectedArticleUrlName) {
                        this.selectedArticle = this.getArticleByUrlName(this.selectedArticleUrlName);
                        if (this.selectedArticle !== undefined) {
                            this.setSelectedItem(this.treeItems, this.selectedArticle.id);
                            this.updateArticleUrlAndTitle(this.selectedArticle);
                        }
                        this.articleSelectedEvent();
                    }
                }
                this.filteredTreeItems = this.treeItems;
                const sortedChapters = [...chapters.entries()]
                    .sort((a, b) => a[1][0].chapterOrder - b[1][0].chapterOrder);
                this.chapterOptions = [
                    {
                        label: this.labels.All_chapters,
                        value: ''
                    },
                    ...sortedChapters.map(([chapter]) => ({
                        label: chapter,
                        value: chapter
                    }))
                ];

                this.filterTreeItems();
                setTimeout(() => {
                    this.scrollToSelectedArticle();
                }, 1000);

                this.isLoading = false;

            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error to get articles:', error);
            });


    }

    getArticleProductByUrlName(urlName) {
        this.isLoading = true;
        getArticleProductByUrlName({ urlName: urlName, language: this.getLanguage() })
            .then((result) => {
                if(result!=null) {
                    this.selectedProduct = result;
                }else{
                    //dispatch event with undefined article
                    this.selectedArticle = undefined;
                    this.articleSelectedEvent();
                }
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;
                console.error('Error fetching product name:', error);
            });
    }
    getArticleByUrlName(urlName) {
        for (let i = 0; i < this.treeItems.length; i++) {
            const chapter = this.treeItems[i];
            for (let j = 0; j < chapter.items.length; j++) {
                const article = chapter.items[j];
                if (article.urlName === urlName) {
                    return article;
                }
            }
        }

    }

    handleTreeSelect(event) {
        const selectedUrlName = event.target.dataset.articleUrlName;
        const article = this.getArticleByUrlName(selectedUrlName);
        if (article) {
            this.selectedArticle = article;
            this.setSelectedItem(this.treeItems, this.selectedArticle.id);
            this.setSelectedItem(this.filteredTreeItems, this.selectedArticle.id);
            this.updateArticleUrlAndTitle(this.selectedArticle);
            this.articleSelectedEvent();
        }
    }

    updateArticleUrlAndTitle(article) {
        const url = new URL(document.URL);
        if (url.searchParams.has('p')) {
            url.searchParams.delete('p');
        }
        url.searchParams.set('u', article.urlName);
        const newUrl = url.toString();
        document.title = article.label;
        if (window.location.href !== newUrl) {
            window.history.pushState({ path: newUrl }, document.title, newUrl);
        }
    }
    articleSelectedEvent() {
        const passEvent = new CustomEvent('articleselected', {
            detail: { article: this.selectedArticle }
        });
        this.dispatchEvent(passEvent);
    }
    productSelectedEvent() {
        const passEvent = new CustomEvent('productselected', {
            detail: { product: this.selectedProduct }
        });
        this.dispatchEvent(passEvent);
    }

    handleProductSelect(event) {
        const selectedProduct = event.target.value !== null && event.target.value !== undefined ? event.target.value : event.target.dataset.value;
        this.selectedProduct = selectedProduct;
        this.selectedChapter = '';
        document.title = 'Docs for ' + this.selectedProduct;
    }

    handleChapterSelect(event) {
        const chapter = event.target.value;
        this.selectedChapter = chapter;
        this.filterTreeItems();
        const passEvent = new CustomEvent('chapterselected', {
            detail: { chapter: chapter }
        });
        this.dispatchEvent(passEvent);
    }

    handleForThisAccFilterChange(event) {
        this.forThisAccFilter = event.target.checked;
        this.filterTreeItems();
    }

    handleIsNewFilterChange(event) {
        this.isNew = event.target.checked;
        this.filterTreeItems();
    }

    handleIsUpdatedFilterChange(event) {
        this.isUpdated = event.target.checked;
        this.filterTreeItems();
    }

    handleIsFavoriteFilterChange(event) {
        this.isFavorite = event.target.checked;
        this.filterTreeItems();
    }

    handleTitleChange(event) {
        this.titleFilter = event.target.value;
        this.filterTreeItems();
    }

    filterTreeItems() {
        const isNew = this.isNew;
        const isUpdated = this.isUpdated;
        const isFavorite = this.isFavorite;
        const forThisAccFilter = this.forThisAccFilter;
        const selectedChapter = this.selectedChapter;
        const titleFilter = this.titleFilter.toLowerCase().trim();

        let filteredTreeItems = this.treeItems.map(chapter => {
            if (selectedChapter !== '' && chapter.label !== selectedChapter) {
                return false;
            }

            let items = chapter.items.filter(item => {
                const titleMatches = titleFilter ? item.label.toLowerCase().includes(titleFilter) : true;
                const matchesFilter = (
                    (!forThisAccFilter && !isNew && !isUpdated && !isFavorite) ||
                    (forThisAccFilter && item.forThisAcc) ||
                    (isNew && item.isNew) ||
                    (isUpdated && item.isUpdated) ||
                    (isFavorite && item.isFavorite)
                );

                return titleMatches && matchesFilter;
            });

            return items.length > 0 ? { ...chapter, items } : false;
        }).filter(Boolean);

        this.filteredTreeItems = filteredTreeItems;
    }

    toggleChapterExpansion(event) {
        const chapterLabel = event.currentTarget.closest('.slds-tree__item').dataset.chapter;
        const updatedTreeItems = this.treeItems.map((chapter) => {
            if (chapter.label === chapterLabel) {
                chapter.expanded = !chapter.expanded;
            }
            return chapter;
        });
        this.filteredTreeItems = [...updatedTreeItems];
    }

    setSelectedItem(treeItems, articleId) {
        treeItems.forEach(chapter => {
            chapter.items.forEach(item => {
                item.selected = item.id === articleId;
            });
        });
    }

    scrollToSelectedArticle() {
        const treeEl = this.template.querySelector('[data-id="knownledgeTree"]');
        if (treeEl) {
            const selectedItemEl = treeEl.querySelector(`[aria-selected = "true"]`);
            if (selectedItemEl) {
                selectedItemEl.scrollIntoView({ behavior: "smooth", block: "end", inline: "center" });
            }
        }
    }
    navigateToFiles() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'See_Files__c'
            },
            state: {
                p: this.selectedProduct
            }
        });
    }
    get hasArticles() {
        return this.filteredTreeItems && this.filteredTreeItems.length > 0 && this.filteredTreeItems.some(chapter => chapter.items && chapter.items.length > 0);
    }

    decodeHtmlEntities(str) {
        const textarea = document.createElement('textarea');
        textarea.innerHTML = str;
        return textarea.value;
    }
}