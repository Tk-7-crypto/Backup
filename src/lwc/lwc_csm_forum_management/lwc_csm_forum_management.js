import { LightningElement, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getProductGroupList from '@salesforce/apex/CNT_CSM_CommunityGroups.getProductGroupList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcCsmForumManagement extends LightningElement {
    @track productGroup = [];
    @track productOptions = [];
    @track selectedProduct = '';
    @track selectedProductName = '';
    @track selectedProductGroups = [];
    @track error;
    draggedGroupId;

    @wire(getProductGroupList)
    wiredProducts({ error, data }) {
        if (data) {
            this.processProductGroups(data);
        } else if (error) {
            this.error = error;
            console.error(error);
        }
    }

    processProductGroups(data) {
        const clonedData = JSON.parse(JSON.stringify(data));
        const noGroupOrder = 999;
        clonedData.sort((a, b) => {
            const orderA = a.groupOrder !== undefined && a.groupOrder !== null ? a.groupOrder : noGroupOrder;
            const orderB = b.groupOrder !== undefined && b.groupOrder !== null ? b.groupOrder : noGroupOrder;
            return orderA - orderB;
        });
    
        const productMap = new Map();
    
        clonedData.forEach(item => {
            const productName = item.productName;
            const relatedGroup = {
                Id: item.relatedGroup.Id,
                Name: item.relatedGroup.Name,
                MemberCount: item.relatedGroup.MemberCount,
                LastFeedModifiedDate: item.relatedGroup.LastFeedModifiedDate,
                LastModifiedDate: item.relatedGroup.LastModifiedDate,
                OwnerId: item.relatedGroup.OwnerId,
                CollaborationType: item.relatedGroup.CollaborationType,
                FullPhotoUrl: item.relatedGroup.FullPhotoUrl,
                InformationBody: item.relatedGroup.InformationBody,
                Owner: item.relatedGroup.Owner,
                Description: item.relatedGroup.Description,
                productGroupId: item.productGroupId,
                groupOrder: item.groupOrder !== undefined && item.groupOrder !== null ? item.groupOrder : noGroupOrder
            };
    
            if (!productMap.has(productName)) {
                productMap.set(productName, {
                    productId: relatedGroup.Id,
                    productName: productName,
                    groups: []
                });
            }
    
            productMap.get(productName).groups.push(relatedGroup);
        });
    
        this.productGroup = Array.from(productMap.values());
        this.productOptions = this.productGroup.map(product => ({
            label: product.productName,
            value: product.productId
        }));
        if (this.productOptions.length > 0) {
            this.selectedProduct = this.productOptions[0].value;
            this.handleProductChange({ detail: { value: this.selectedProduct } });
        }
    }

    handleProductChange(event) {
        this.selectedProduct = event.detail.value;
        const selectedProduct = this.productGroup.find(product => product.productId === this.selectedProduct);
        if (selectedProduct) {
            this.selectedProductName = selectedProduct.productName;
            this.selectedProductGroups = selectedProduct.groups;
        } else {
            this.selectedProductName = '';
            this.selectedProductGroups = [];
        }
    }

    handleDragStart(event) {
        this.draggedGroupId = event.currentTarget.dataset.id;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        const droppedGroupId = event.currentTarget.dataset.id;

        if (this.draggedGroupId && droppedGroupId && this.draggedGroupId !== droppedGroupId) {
            const productIndex = this.productGroup.findIndex(product =>
                product.groups.some(group => group.Id === this.draggedGroupId)
            );

            if (productIndex !== -1) {
                const groupDetails = this.productGroup[productIndex].groups;
                const draggedIndex = groupDetails.findIndex(item => item.Id === this.draggedGroupId);
                const droppedIndex = groupDetails.findIndex(item => item.Id === droppedGroupId);
                const newItems = [...groupDetails];
                const [movedItem] = newItems.splice(draggedIndex, 1);
                newItems.splice(droppedIndex, 0, movedItem);

                newItems.forEach((item, index) => {
                    item.groupOrder = index + 1;
                });

                this.productGroup[productIndex].groups = newItems;
                this.selectedProductGroups = newItems;
                this.draggedGroupId = null;
                this.saveOrder(newItems);
            }
        }
    }


    saveOrder(groupDetails) {
        const recordUpdates = groupDetails.map(item => {
            return {
                fields: {
                    Id: item.productGroupId,
                    Group_Order__c: item.groupOrder
                }
            };
        });

        Promise.all(recordUpdates.map(updateRecord))
            .then(() => {
                console.log('Order saved successfully');
            })
            .catch(error => {
                console.error('Error saving order:', error);
                this.showToast('Error', 'Error saving order', 'error');
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
}
