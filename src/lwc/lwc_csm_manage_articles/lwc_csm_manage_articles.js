import { LightningElement, track } from 'lwc';
import { updateRecord, createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import getArticleChapters from '@salesforce/apex/CNT_CSM_CaseCategorization.getArticleChapters';
import getAvailableProductsForAddArticleChapters from '@salesforce/apex/CNT_CSM_CaseCategorization.getAvailableProductsForAddArticleChapters';
import getKnowledgeArticles from '@salesforce/apex/CNT_CSM_CaseCategorization.getKnowledgeArticles';
import saveArticleOrder from '@salesforce/apex/CNT_CSM_CaseCategorization.saveArticleOrder';

export default class Lwc_csm_manage_articles extends LightningElement {
    @track items = [];
    @track pillarOptions = [];
    @track productOptions = [];
    @track selectedPillar;
    @track selectedProductId;
    @track selectedProductName;
    @track availableProducts = [];
    @track selectedNewProductId;
    @track newProductChapters = '';
    @track selectedChapterArticles = [];
    @track selectedChapterName = '';
    draggedItemId;
    draggedArticleId;
    pillarProductArticleChapters = [];
    newChapters = '';
    isModalOpen = false;

    connectedCallback() {
        this.loadArticleChapters();
    }

    loadArticleChapters() {
        getArticleChapters()
            .then(result => {
                let pillarProductMap = new Map();
                result.forEach(prod => {
                    let key = `${prod.Pillar__c}-${prod.Product__c}`;
                    if (!pillarProductMap.has(key)) {
                        pillarProductMap.set(key, {
                            pillar: prod.Pillar__c,
                            product: prod.Product__c,
                            productName: prod.ProductName__c,
                            chapters: []
                        });
                    }
                    pillarProductMap.get(key).chapters.push({
                        Id: prod.Id,
                        Article_Chapter__c: prod.Article_Chapter__c,
                        Article_Chapter_Order__c: prod.Article_Chapter_Order__c
                    });
                });

                this.pillarProductArticleChapters = Array.from(pillarProductMap.values());

                this.pillarOptions = [...new Set(result.map(item => item.Pillar__c))].map(pillar => ({
                    label: pillar,
                    value: pillar
                }));

                if (this.pillarOptions.length > 0) {
                    this.selectedPillar = this.pillarOptions[0].value;
                    this.loadProducts();
                }
            })
            .catch(error => {
                console.error('Error fetching article chapters:', error);
            });
    }

    loadProducts() {
        this.productOptions = this.pillarProductArticleChapters
            .filter(item => item.pillar === this.selectedPillar)
            .map(item => ({
                label: item.productName,
                value: item.product
            }));

        if (this.productOptions.length > 0) {
            if(!this.selectedProductId){
                this.selectedProductId = this.productOptions[0].value;
                this.selectedProductName = this.productOptions[0].label;
            } 
            this.loadChapters();
        } else {
            this.items = [];
        }
    }

    handlePillarChange(event) {
        this.selectedPillar = event.detail.value;
        this.loadProducts();
    }

    handleProductChange(event) {
        this.selectedProductId = event.detail.value;
        const selectedProduct = this.productOptions.find(product => product.value === this.selectedProductId);
        this.selectedProductName = selectedProduct ? selectedProduct.label : '';
        this.selectedChapterName = '';
        this.loadChapters();
    }

    loadChapters() {
        const selectedChapter = this.pillarProductArticleChapters.find(
            item => item.pillar === this.selectedPillar && item.product === this.selectedProductId
        );

        if (selectedChapter) {
            this.items = [...selectedChapter.chapters];
            this.items.sort((a, b) => {
                if (a.Article_Chapter_Order__c && b.Article_Chapter_Order__c) {
                    return a.Article_Chapter_Order__c - b.Article_Chapter_Order__c;
                } else if (a.Article_Chapter_Order__c) {
                    return -1;
                } else if (b.Article_Chapter_Order__c) {
                    return 1;
                } else {
                    const nameA = a.Article_Chapter__c.toUpperCase();
                    const nameB = b.Article_Chapter__c.toUpperCase();
                    if (nameA < nameB) {
                        return -1;
                    }
                    if (nameA > nameB) {
                        return 1;
                    }
                    return 0;
                }
            });
        } else {
            this.items = [];
        }
    }

    handleDragStart(event) {
        this.draggedItemId = event.currentTarget.dataset.id;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        const draggedItemId = this.draggedItemId;
        const droppedItemId = event.currentTarget.dataset.id;

        if (draggedItemId && droppedItemId) {
            const draggedIndex = this.items.findIndex(item => item.Id === draggedItemId);
            const droppedIndex = this.items.findIndex(item => item.Id === droppedItemId);

            const newItems = [...this.items];
            const [movedItem] = newItems.splice(draggedIndex, 1);
            newItems.splice(droppedIndex, 0, movedItem);

            this.items = newItems;

            newItems.forEach((item, index) => {
                item.Article_Chapter_Order__c = index + 1;
            });

            this.saveOrder();
        }
    }

    handleTextareaChange(event) {
        this.newChapters = event.target.value;
    }

    handleAddChapters() {
        if (this.newChapters.trim() && this.selectedProductId) {
            const chapterNames = this.newChapters.split('\n').map(name => name.trim()).filter(name => name);
            const uniqueChapterNames = [...new Set(chapterNames)];
            const existingChapters = this.pillarProductArticleChapters.find(
                item => item.pillar === this.selectedPillar && item.product === this.selectedProductId
            )?.chapters.map(chapter => chapter.Article_Chapter__c) || [];
            const newChapterNames = uniqueChapterNames.filter(name => !existingChapters.includes(name));
            if (newChapterNames.length > 0) {
                const createPromises = newChapterNames.map(chapterName => {
                    const newChapter = {
                        Product__c: this.selectedProductId,
                        Article_Chapter__c: chapterName,
                        Pillar__c: this.selectedPillar,
                        Type__c: 'Knowledge'
                    };
                    return createRecord({ apiName: 'CSM_QI_Case_Categorization__c', fields: newChapter });
                });
    
                Promise.all(createPromises)
                    .then(results => {
                        results.forEach(createdRecord => {
                            const newChapterId = createdRecord.id;
                            const pillarProductIndex = this.pillarProductArticleChapters.findIndex(
                                item => item.pillar === this.selectedPillar && item.product === this.selectedProductId
                            );
    
                            this.pillarProductArticleChapters[pillarProductIndex].chapters.push({
                                Id: newChapterId,
                                Article_Chapter__c: newChapterNames.shift(),
                                Article_Chapter_Order__c: null
                            });
                        });
    
                        this.loadProducts();
                        this.showToast('Success', 'New chapters added successfully', 'success');
                    })
                    .catch(error => {
                        console.error('Error creating new chapters:', error);
                        this.showToast('Error', 'Error creating new chapters', 'error: ' + error.body.message);
                    });
    
                this.newChapters = '';
            } else {
                this.showToast('Error', 'All entered chapters already exist or are duplicates', 'error');
            }
        } else {
            this.showToast('Error', 'Please enter chapter names', 'error');
        }
    }
    

    async handleDeleteChapter(event) {
        const chapterId = event.currentTarget.dataset.id;

        if (chapterId) {
            const confirmed = await LightningConfirm.open({
                message: 'Articles that already have this chapter will not be changed, but articles can no longer be defined with this chapter. Do you want to proceed?',
                variant: 'warning',
                label: 'Confirm Deletion',
                theme: 'error'
            });

            if (confirmed) {
                deleteRecord(chapterId)
                    .then(() => {
                        this.showToast('Success', 'Chapter deleted successfully', 'success');
                        this.pillarProductArticleChapters.forEach(pillarProduct => {
                            const chapterIndex = pillarProduct.chapters.findIndex(chapter => chapter.Id === chapterId);
                            if (chapterIndex !== -1) {
                                pillarProduct.chapters.splice(chapterIndex, 1);
                            }
                        });
                        this.loadProducts();
                    })
                    .catch(error => {
                        console.error('Error deleting chapter:', error);
                        this.showToast('Error', 'Error deleting chapter', 'error: ' + error.body.message);
                    });
            }
        }
    }

    saveOrder() {
        const recordUpdates = [];

        this.items.forEach(item => {
            const record = {
                fields: {
                    Id: item.Id,
                    Article_Chapter_Order__c: item.Article_Chapter_Order__c
                }
            };
            recordUpdates.push(updateRecord(record));
        });

        Promise.all(recordUpdates)
            .then(() => {
                console.log('Chapter order saved successfully');
            })
            .catch(error => {
                console.error('Error saving order:', error);
                this.showToast('Error', 'Error saving order', 'error: ' + error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    openModal() {
        getAvailableProductsForAddArticleChapters({ pillar: this.selectedPillar })
            .then(result => {
                this.availableProducts = result.map(product => ({
                    label: product.Name,
                    value: product.Id
                })).sort((a, b) => {
                    if (a.label < b.label) {
                        return -1;
                    }
                    if (a.label > b.label) {
                        return 1;
                    }
                    return 0;
                });
                this.isModalOpen = true;
            })
            .catch(error => {
                console.error('Error fetching available products:', error);
                this.showToast('Error', 'Error fetching available products', 'error: ' + error.body.message);
            });
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedNewProductId = null;
        this.newProductChapters = '';
    }

    handleNewProductChange(event) {
        this.selectedNewProductId = event.detail.value;
    }

    handleNewProductChaptersChange(event) {
        this.newProductChapters = event.target.value;
    }

    handleAddNewProduct() {
        if (this.newProductChapters.trim() && this.selectedNewProductId) {
            const chapterNames = this.newProductChapters.split('\n').map(name => name.trim()).filter(name => name);
            const uniqueChapterNames = [...new Set(chapterNames)];
    
            if (uniqueChapterNames.length > 0) {
                const selectedProduct = this.availableProducts.find(product => product.value === this.selectedNewProductId);
                const selectedNewProductName = selectedProduct ? selectedProduct.label : '';
    
                const createChapterPromises = uniqueChapterNames.map(chapterName => {
                    const newChapter = {
                        Product__c: this.selectedNewProductId,
                        Article_Chapter__c: chapterName,
                        Pillar__c: this.selectedPillar,
                        Type__c: 'Knowledge'
                    };
                    return createRecord({ apiName: 'CSM_QI_Case_Categorization__c', fields: newChapter });
                });
    
                Promise.all(createChapterPromises)
                    .then(results => {
                        results.forEach(createdRecord => {
                            const newChapterId = createdRecord.id;
                            const newChapter = {
                                Id: newChapterId,
                                Article_Chapter__c: uniqueChapterNames.shift(),
                                Article_Chapter_Order__c: null
                            };
                            const pillarProductIndex = this.pillarProductArticleChapters.findIndex(
                                item => item.pillar === this.selectedPillar && item.product === this.selectedNewProductId
                            );
                            if (pillarProductIndex !== -1) {
                                this.pillarProductArticleChapters[pillarProductIndex].chapters.push(newChapter);
                            } else {
                                this.pillarProductArticleChapters.push({
                                    pillar: this.selectedPillar,
                                    product: this.selectedNewProductId,
                                    productName: selectedNewProductName,
                                    chapters: [newChapter]
                                });
                            }
                        });
                        return this.loadProducts();
                    })
                    .then(() => {
                        this.selectedProductId = this.selectedNewProductId;
                        this.handleProductChange({ detail: { value: this.selectedNewProductId } });
                        this.showToast('Success', 'New product and chapters added successfully', 'success');
                        this.closeModal();
                    })
                    .catch(error => {
                        console.error('Error creating new chapters:', error);
                        this.showToast('Error', 'Error creating new chapters', 'error: ' + error.body.message);
                    });
            } else {
                this.showToast('Error', 'Please enter at least one unique chapter name', 'error');
            }
        } else {
            this.showToast('Error', 'Please select a product and enter chapter names', 'error');
        }
    }
    

    handleShowArticles(event) {
        const article_chapter = event.currentTarget.dataset.chapter;
        const productName = this.selectedProductName;
        const pillar = this.selectedPillar;

        getKnowledgeArticles({ articleChapter: article_chapter, productName: productName, pillar: pillar })
            .then(result => {
                console.log('result',JSON.stringify(result));
                const articlesItem = [...result];
                articlesItem.sort((a, b) => a.order - b.order);
                this.selectedChapterArticles = articlesItem.map(item => item.article);
                this.selectedChapterName = article_chapter;
            })
            .catch(error => {
                console.error('Error fetching knowledge articles:', error);
                this.showToast('Error', 'Error fetching knowledge articles', 'error: ' + error.body.message);
            });
    }

    handleDragStartArticle(event) {
        this.draggedArticleId = event.currentTarget.dataset.id;
    }

    handleDropArticle(event) {
        const draggedArticleId = this.draggedArticleId;
        const droppedArticleId = event.currentTarget.dataset.id;

        if (draggedArticleId && droppedArticleId) {
            const draggedIndex = this.selectedChapterArticles.findIndex(article => article.Id === draggedArticleId);
            const droppedIndex = this.selectedChapterArticles.findIndex(article => article.Id === droppedArticleId);

            const newArticles = [...this.selectedChapterArticles];
            const [movedArticle] = newArticles.splice(draggedIndex, 1);
            newArticles.splice(droppedIndex, 0, movedArticle);

            this.selectedChapterArticles = newArticles;

            const articleWrappers = newArticles.map((article, index) => {
                return { article: article, order: index + 1 };
            });

            saveArticleOrder({ articleWrappers })
                .then(() => {
                    console.log('Article order saved successfully');
                })
                .catch(error => {
                    console.error('Error saving article order:', error);
                    this.showToast('Error', 'Error saving article order', 'error: ' + error.body.message);
                });
        }
    }

    get hasArticles() {
        return this.selectedChapterArticles.length > 0;
    }
    


}
