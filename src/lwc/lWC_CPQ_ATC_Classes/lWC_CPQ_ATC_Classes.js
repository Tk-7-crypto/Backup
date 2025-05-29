import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getATC_Classes from '@salesforce/apex/CNT_CPQ_ATCClassesController.getATC_Classes';
import saveMarketShare from '@salesforce/apex/CNT_CPQ_ATCClassesController.saveMarketShare';
import handleCancle from '@salesforce/apex/CNT_CPQ_ATCClassesController.handleCancle';

const COLS = [{
    fieldName: 'name',
    label: 'ATC/OTC Classification'
},
{
    fieldName: 'marketShare',
    label: 'Market Share',
},
{
    fieldName: 'quarter',
    label: 'Quarter',
}];

export default class ATC_OTC_Classification extends LightningElement {
    @track myData = [];
    @track myDataObj = [];
    @track selectedRows = [];
    @track expandedRows = [];
    @track currentSelectedRows = [];
    @track atc1ToATC2Map = new Map();
    @track atc2ToATC3Map = new Map();
    @track atc3ToATC4Map = new Map();
    @track atcToMarketShareMap = new Map();
    @track childToParentMap = new Map();
    @track currentPageReference;
    totalMarketShare = 0.00;
    showSelectedVisible = false;
    showSelectedRows = [];
    showNotFoundCodes = [];
    showNotFoundVisible = false;
    columns = COLS;
    atcotcCount = 0;
    aggregateMapJSON;
    error;
    @track selectedATCOTCCode = "";
    @track atcCodes = new Set();
    @track type = '';
    @track parentToAllRelatedChildMap = new Map();
    @track atcToQuarterMap = new Map();
    @track atcToMarketShareValueMap = new Map();
    @api currentQuarter = [];
    loaded = true;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.columns = [...COLS].filter(col => col.fieldName != 'quarter');
        getATC_Classes({lineItemId: currentPageReference.state?.c__Id})
        .then(result => {
            var temps = result.split('&&&');
            this.type = temps[1];
            var strData1 = JSON.parse(temps[0]);
            var strData2 = JSON.parse(JSON.stringify(strData1).split('items').join('_children'));
            this.myData = strData2;
            this.myDataObj = strData1;
            strData1.forEach(level1 => {
                var tempList1 = [];
                var firstLevelParentChild = [];
                level1.items.forEach(level2 => {
                    var secondLevelParentChild = [];
                    firstLevelParentChild.push(level2.name);
                    tempList1.push(level2.name);
                    var tempList2 = [];
                    level2.items.forEach(level3 => {
                        var thirdLevelParentChild = [];
                        firstLevelParentChild.push(level3.name);
                        secondLevelParentChild.push(level3.name);
                        tempList2.push(level3.name);
                        var tempList3 = [];
                        if(level3.items != null) {
                            level3.items.forEach(level4 => {
                                firstLevelParentChild.push(level4.name);
                                secondLevelParentChild.push(level4.name);
                                thirdLevelParentChild.push(level4.name);
                                tempList3.push(level4.name);
                                if(level4.marketShareWithPrecision != null){
                                    this.atcToMarketShareMap.set(level4.name, level4.marketShareWithPrecision);
                                    this.atcToMarketShareValueMap.set(level4.name, level4.marketShareValue);
                                }
                                if(level4.quarter != null){
                                    this.atcToQuarterMap.set(level4.name, level4.quarter);
                                }
                                this.childToParentMap.set(level4.name, level3.name);
                            })
                            this.parentToAllRelatedChildMap.set(level1.name, firstLevelParentChild);
                            this.parentToAllRelatedChildMap.set(level2.name, secondLevelParentChild);
                            this.parentToAllRelatedChildMap.set(level3.name, thirdLevelParentChild);
                            this.atc3ToATC4Map.set(level3.name, tempList3);
                        }
                        if(level3.marketShareWithPrecision != null){
                            this.atcToMarketShareMap.set(level3.name, level3.marketShareWithPrecision);
                            this.atcToMarketShareValueMap.set(level3.name, level3.marketShareValue);
                        }
                        if(level3.quarter != null){
                            this.atcToQuarterMap.set(level3.name, level3.quarter);
                        }
                        this.childToParentMap.set(level3.name, level2.name);
                    })
                    this.childToParentMap.set(level2.name, level1.name);
                    this.atc2ToATC3Map.set(level2.name, tempList2);
                })
                this.atc1ToATC2Map.set(level1.name, tempList1);
            })
            var temp = [];
            var previousSelectedHierarchyName = new Set();
            if(temps[3] != 'null'){
                this.totalMarketShare = temps[3];
            }else{
                this.totalMarketShare = '0.00';
            }
            if(temps[2] != 'null'){
                this.selectedATCOTCCode = temps[2];
                temp = temps[2].split(';');
                temp[0] = temp[0].split(' ').pop();
                temp.forEach(element => {
                    this.atcCodes.add(element);
                    for (const [key, value] of this.childToParentMap.entries()) {
                        var temp1 = key.split(" ");
                        var temp2 = value.split(" ");
                        if(element == temp1[0]){
                            previousSelectedHierarchyName.add(key);
                        }else if(element == temp2[0]){
                            previousSelectedHierarchyName.add(value);
                        }  
                    }
                });
                this.selectedRows = this.selectedRows.concat(Array.from(previousSelectedHierarchyName));
                this.showSelectedRows = this.showSelectedRows.concat(Array.from(previousSelectedHierarchyName).sort());
                var rowsToExpand = [];
                rowsToExpand = rowsToExpand.concat(Array.from(previousSelectedHierarchyName));
                previousSelectedHierarchyName.forEach(element => {
                    for (let [key, value] of this.parentToAllRelatedChildMap.entries()) {
                        if(value.indexOf(element) >= 0){
                            rowsToExpand.push(key);
                        }
                    }
                });
                this.expandedRows = this.expandedRows.concat(rowsToExpand);
                this.showSelectedVisible = true;
            }
        })
        .catch(error => {
            var errMessage = error.body.message;
            this.showToast("Error", "error", errMessage);
            this.error = error;
        });
    }
    get recordId() {
        return this.currentPageReference?.state?.c__Id;
    }

    updateSelectedRows() {
        this.atcCodes = new Set();
        var tempList = [];
        var selectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
        var expandedRows = this.template.querySelector('lightning-tree-grid').getCurrentExpandedRows();
        if(selectRows.length > 0){
            selectRows.forEach(record => {
                tempList.push(record.name);
            })
            // select and deselect child rows based on header row
            this.myDataObj.forEach(record => {
                // if header was checked and remains checked, do not add sub-rows

                // if header was not checked but is now checked, add sub-rows
                if(!this.currentSelectedRows.includes(record.name) && tempList.includes(record.name)) {
                    record.items.forEach(item => {
                        item.items.forEach(item => {
                            if(item.items != null) {
                                item.items.forEach(item => {
                                    if(!tempList.includes(item.name)) {
                                        tempList.push(item.name);
                                    }
                                })
                            }
                            if(!tempList.includes(item.name)) {
                                tempList.push(item.name);
                            }
                        })
                        if(!tempList.includes(item.name)) {
                            tempList.push(item.name);
                        }
                    })
                }else {
                    record.items.forEach(item => {
                        if(!this.currentSelectedRows.includes(item.name) && tempList.includes(item.name)) {
                            item.items.forEach(item => {
                                if(item.items != null) {
                                    item.items.forEach(item => {
                                        if(!tempList.includes(item.name)) {
                                            tempList.push(item.name);
                                        }
                                    })
                                }
                                if(!tempList.includes(item.name)) {
                                    tempList.push(item.name);
                                }
                            })
                        }
                        else {
                            item.items.forEach(item => {
                                if(!this.currentSelectedRows.includes(item.name) && tempList.includes(item.name)) {
                                    if(item.items != null) {
                                        item.items.forEach(item => {
                                            if(!tempList.includes(item.name)) {
                                                tempList.push(item.name);
                                            }
                                        })
                                    }
                                    if(!tempList.includes(item.name)) {
                                        tempList.push(item.name);
                                    }
                                }
                            })
                        }
                    })
                }

                // if header was checked and is no longer checked, remove header and sub-rows
                if(this.currentSelectedRows.includes(record.name) && !tempList.includes(record.name)) {
                    record.items.forEach(item => {
                        item.items.forEach(item => {
                            if(item.items != null) {
                                item.items.forEach(item => {
                                    const index = tempList.indexOf(item.name);
                                    if(index > -1) {
                                        tempList.splice(index, 1);
                                    }
                                })
                            }
                            const index = tempList.indexOf(item.name);
                            if(index > -1) {
                                tempList.splice(index, 1);
                            }
                        })
                        const index = tempList.indexOf(item.name);
                        if(index > -1) {
                            tempList.splice(index, 1);
                        }
                    })
                }
                else{
                    record.items.forEach(item => {
                        if(this.currentSelectedRows.includes(item.name) && !tempList.includes(item.name)) {
                            item.items.forEach(item => {
                                if(item.items != null) {
                                    item.items.forEach(item => {
                                        const index = tempList.indexOf(item.name);
                                        if(index > -1) {
                                            tempList.splice(index, 1);
                                        }
                                    })
                                }
                                const index = tempList.indexOf(item.name);
                                if(index > -1) {
                                    tempList.splice(index, 1);
                                }
                            })
                        }
                        else{
                            item.items.forEach(item => {
                                if(this.currentSelectedRows.includes(item.name) && !tempList.includes(item.name)) {
                                    if(item.items != null) {
                                        item.items.forEach(item => {
                                            const index = tempList.indexOf(item.name);
                                            if(index > -1) {
                                                tempList.splice(index, 1);
                                            }
                                        })
                                    }
                                    const index = tempList.indexOf(item.name);
                                    if(index > -1) {
                                        tempList.splice(index, 1);
                                    }
                                }
                            })
                        }
                    })
                }

                // if all child rows for the header row are checked, add the header
                // else remove the header
                var allSelected = true;
                if(expandedRows.includes(record.name)) {
                    record.items.forEach(item => {
                        if(expandedRows.includes(item.name)) {
                            item.items.forEach(item => {
                                if(expandedRows.includes(item.name)) {
                                    if(item.items){
                                        item.items.forEach(item => {
                                            if(!tempList.includes(item.name)) {
                                                allSelected = false;
                                            }
                                        })
                                        if(!allSelected && tempList.includes(item.name)){
                                            const index = tempList.indexOf(item.name);
                                            if(index > -1) {
                                                tempList.splice(index, 1);
                                            }
                                        }
                                        else if(allSelected && !tempList.includes(item.name)) {
                                            tempList.push(item.name);
                                        }
                                    }
                                }
                                if(!tempList.includes(item.name)) {
                                    allSelected = false;
                                }
                            })
                            if(!allSelected && tempList.includes(item.name)){
                                const index = tempList.indexOf(item.name);
                                if(index > -1) {
                                    tempList.splice(index, 1);
                                }
                            }
                            else if(allSelected && !tempList.includes(item.name)) {
                                tempList.push(item.name);
                            }
                        }
                        if(!tempList.includes(item.name)) {
                            allSelected = false;
                        }
                    })
                    if(allSelected && !tempList.includes(record.name)) {
                        tempList.push(record.name);
                    } 
                    else if(!allSelected && tempList.includes(record.name)) {
                        const index = tempList.indexOf(record.name);
                        if(index > -1) {
                            tempList.splice(index, 1);
                        }
                    }
                }
            })
            this.selectedRows = tempList;
            this.currentSelectedRows = tempList;
            var allSelectedHierarchy = [];
            tempList.forEach(element => {
                allSelectedHierarchy.push(element);
                allSelectedHierarchy = allSelectedHierarchy.concat(this.getBykey(this.parentToAllRelatedChildMap, element));
            });
            selectRows.forEach(element => {
                allSelectedHierarchy.push(element.name);
            });
            allSelectedHierarchy = allSelectedHierarchy.filter(element => {
                return element !== undefined;
            });
            if(allSelectedHierarchy.length > 0){
                allSelectedHierarchy.forEach(element => {
                    var temp = element.split(" ");
                    this.atcCodes.add(temp[0]);
                });
            }
            var tempCon = (Array.from(this.atcCodes).join(";")).toString();
            this.selectedATCOTCCode = this.type + 's: ' + tempCon;
        }
    }
    handleRowToggle(event) {
        var tempList = [];
        var showSelected = [];
        const row = event.detail.row;
        var selectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
        selectRows.forEach(record => {
            if(row.name == record.name){
                row._children.forEach(item => {
                    tempList.push(item.name);
                })
            }
            tempList.push(record.name);
        })
        if(tempList.length > 0){
            this.selectedRows = tempList;
            this.currentSelectedRows = tempList;
        }
    }

    handleSave() {
        var finalQuarter;
        this.loaded = !this.loaded;
        this.handleCalculate();
        var cartLink;
        var totalCalculatedMarketShare = this.totalMarketShare;
        finalQuarter = this.currentQuarter[this.currentQuarter.length -1];
        saveMarketShare({lineItemId: this.recordId, marketShare: totalCalculatedMarketShare, selectedAtcOtcCodes: this.selectedATCOTCCode, financialQuarter:finalQuarter, selectedATCOTCAggregateJSON: this.aggregateMapJSON})
        .then(result => {
            this.showToast("Success", "success", "Market Share Saved Successfully");
            cartLink = result;
            window.open(cartLink, "_self");
        })
        .catch(error => {
            var errMessage = error;
            this.showToast("Error", "error", errMessage);
            this.error = error;
        });
    }

    handleCalculate() {
        var addMarketShare = 0.00;
        var showSelected = [];
        var sumMarketShareValue = 0;
        var selectedMarketShareList = [];
        var selectedMarketShareValueList = [];
        var selectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
        selectRows.forEach(record => {
            var templist1 = [];
            templist1 = this.atc1ToATC2Map.get(record.name);
            if(templist1 != null && templist1.length > 0){
                for (let name1 of templist1) {
                    var templist2 = [];
                    templist2 = this.atc2ToATC3Map.get(name1);
                    if(templist2.length > 0){
                        for (let name2 of templist2) {
                            var templist3 = [];
                            templist3 = this.atc3ToATC4Map.get(name2);
                            if(templist3 != null){
                                for (let name3 of templist3) {
                                    addMarketShare = addMarketShare + this.atcToMarketShareMap.get(name3);
                                    sumMarketShareValue = sumMarketShareValue + this.atcToMarketShareValueMap.get(name3);
                                    selectedMarketShareList.push(this.atcToMarketShareMap.get(name3));
                                    selectedMarketShareValueList.push(this.atcToMarketShareValueMap.get(name3));
                                    showSelected.push(name3);
                                    if(this.atcToQuarterMap.has(name3)){
                                        this.currentQuarter.push(this.atcToQuarterMap.get(name3));
                                    }
                                }
                            }
                            else{
                                addMarketShare = addMarketShare + this.atcToMarketShareMap.get(name2);
                                sumMarketShareValue = sumMarketShareValue + this.atcToMarketShareValueMap.get(name2);
                                selectedMarketShareList.push(this.atcToMarketShareMap.get(name2));
                                selectedMarketShareValueList.push(this.atcToMarketShareValueMap.get(name2));
                                if(this.atcToQuarterMap.has(name2)){
                                    this.currentQuarter.push(this.atcToQuarterMap.get(name2));
                                }
                            }
                            showSelected.push(name2);
                        }
                    }
                    showSelected.push(name1);
                }
            }
            else{
                var templist2 = [];
                templist2 = this.atc2ToATC3Map.get(record.name);
                if(templist2 != null && templist2.length > 0){
                    for (let name2 of templist2) {
                        if(!showSelected.includes(name2)){
                            var templist3 = [];
                            templist3 = this.atc3ToATC4Map.get(name2);
                            if(templist3 != null){
                                for (let name3 of templist3) {
                                    addMarketShare = addMarketShare + this.atcToMarketShareMap.get(name3);
                                    sumMarketShareValue = sumMarketShareValue + this.atcToMarketShareValueMap.get(name3);
                                    selectedMarketShareList.push(this.atcToMarketShareMap.get(name3));
                                    selectedMarketShareValueList.push(this.atcToMarketShareValueMap.get(name3));
                                    showSelected.push(name3);
                                    if(this.atcToQuarterMap.has(name3)){
                                        this.currentQuarter.push(this.atcToQuarterMap.get(name3));
                                    }
                                }
                            }
                            else{
                                addMarketShare = addMarketShare + this.atcToMarketShareMap.get(name2);
                                sumMarketShareValue = sumMarketShareValue + this.atcToMarketShareValueMap.get(name2);
                                selectedMarketShareList.push(this.atcToMarketShareMap.get(name2));
                                selectedMarketShareValueList.push(this.atcToMarketShareValueMap.get(name2));
                                if(this.atcToQuarterMap.has(name2)){
                                    this.currentQuarter.push(this.atcToQuarterMap.get(name2));
                                }
                            }
                            showSelected.push(name2);
                        }
                    }
                }
                else{
                    var templist3 = [];
                    templist3 = this.atc3ToATC4Map.get(record.name);
                    if(templist3 != null){
                        for (let name3 of templist3) {
                            if(!showSelected.includes(name3)){
                                addMarketShare = addMarketShare + this.atcToMarketShareMap.get(name3);
                                sumMarketShareValue = sumMarketShareValue + this.atcToMarketShareValueMap.get(name3);
                                selectedMarketShareList.push(this.atcToMarketShareMap.get(name3));
                                selectedMarketShareValueList.push(this.atcToMarketShareValueMap.get(name3));
                                showSelected.push(name3);
                                if(this.atcToQuarterMap.has(name3)){
                                    this.currentQuarter.push(this.atcToQuarterMap.get(name3));
                                }
                            }
                        }
                    }
                    else if(record.marketShareWithPrecision != null && !showSelected.includes(record.name)){
                        addMarketShare = addMarketShare + record.marketShareWithPrecision;
                        sumMarketShareValue = sumMarketShareValue + record.marketShareValue;
                        selectedMarketShareList.push(record.marketShareWithPrecision);
                        selectedMarketShareValueList.push(record.marketShareValue);
                        showSelected.push(record.name);
                        if(this.atcToQuarterMap.has(record.name)){
                            this.currentQuarter.push(this.atcToQuarterMap.get(record.name));
                        }
                    }
                }
            }
            if(!showSelected.includes(record.name)){
                showSelected.push(record.name);
            }
        })
        if(showSelected.length > 0){
            this.showSelectedVisible = true;
        }else{
            this.showSelectedVisible = false;
        }
        showSelected.sort();
        this.currentQuarter.sort();
        this.showSelectedRows = showSelected;
        this.totalMarketShare = (Math.round(addMarketShare * 100) / 100).toFixed(2);
        this.atcotcCount = selectedMarketShareList.length;
        var aggregateMap = new Map();
        aggregateMap.set('Count', this.atcotcCount);
        aggregateMap.set('SumMarketShare', addMarketShare);
        aggregateMap.set('SumMarketShareValue', sumMarketShareValue);
        aggregateMap.set('MinMarketShare', Math.min(...selectedMarketShareList));
        aggregateMap.set('MaxMarketShare', Math.max(...selectedMarketShareList));
        aggregateMap.set('MinMarketShareValue', Math.min(...selectedMarketShareValueList));
        aggregateMap.set('MaxMinMarketShareValue', Math.max(...selectedMarketShareValueList));
        var obj = Object.fromEntries(aggregateMap);
        this.aggregateMapJSON = JSON.stringify(obj);
    }
	
    handleCancle() {
        var cartLink;
        handleCancle({lineItemId: this.recordId})
        .then(result => {
            cartLink = result;
            window.open(cartLink, "_self");
        })
        .catch(error => {
            var errMessage = error;
            this.showToast("Error", "error", errMessage);
            this.error = error;
        });
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
	
    handleSelect() {
        var existSelectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
        var existExpandedRows = this.template.querySelector('lightning-tree-grid').getCurrentExpandedRows();
        var temp = [this.template.querySelector('lightning-textarea').value];
        var atcOTCCodes = [temp.toString().toUpperCase()];
        const pattern = /^[a-zA-Z0-9]+(?:;[a-zA-Z0-9]+)*[a-zA-Z0-9]$/;
        const pattern1 = /^[a-zA-Z0-9]+(?:;[a-zA-Z0-9]+)*$/;

        if((!pattern.test(atcOTCCodes.toString()) && !pattern1.test(atcOTCCodes.toString())) && atcOTCCodes.toString().includes(";")){
            this.showToast('Error', 'Error', 'Please enter ATC/OTC in correct Format');
        }else{
            var parentCode = [];
            if(atcOTCCodes.length > 0){
                parentCode = atcOTCCodes[0].split(';');
            }
            var temp = [];
            parentCode.forEach(element => {
                var hierarchyFullName;
                for (const [key, value] of this.childToParentMap.entries()) {
                    var temp1 = key.split(" ");
                    var temp2 = value.split(" ");
                    if(element == temp1[0]){
                        hierarchyFullName = (key);
                        break;
                    }else if(element == temp2[0]){
                        hierarchyFullName = (value);
                        break;
                    }  
                }
                if(hierarchyFullName && this.getBykey(this.parentToAllRelatedChildMap, hierarchyFullName)){
                    temp = temp.concat(this.getBykey(this.parentToAllRelatedChildMap, hierarchyFullName));
                }else{
                    temp = temp.concat(hierarchyFullName);
                }
            });
            temp = temp.filter(element => {
                return element !== undefined;
            });
            temp.forEach(element => {
                this.atcCodes.add(element.split(' ')[0]);
            });
            this.selectedATCOTCCode = this.type + 's: ' + (Array.from(this.atcCodes).join(";")).toString();
            
            var selectRows =[];
            var expandRows =[];
            var notFoundCodeList = new Set();
            if(existSelectRows.length > 0){
                existSelectRows.forEach(record => {
                    selectRows.push(record.name);
                })
            }
            if(existExpandedRows.length > 0){
                existExpandedRows.forEach(record => {
                    expandRows.push(record);
                })
            }
            if(atcOTCCodes[0] != null && atcOTCCodes[0] != ''){
                var atcOTCCodeList = atcOTCCodes[0].split(";");
                atcOTCCodeList.forEach(atcOTCCode => {
                    var isFound = false;
                    for (let temp of this.atc1ToATC2Map.keys()) {
                        var tempExp = this.createRegExp(temp);
                        var result = atcOTCCode.match(tempExp);
                        if(result != null) {
                            selectRows.push(temp);
                            isFound = true;
                        }
                    }
                    if(!isFound){
                        for (let temp of this.atc2ToATC3Map.keys()) {
                            var tempExp = this.createRegExp(temp);
                            var result = atcOTCCode.match(tempExp);
                            if(result != null) {
                                selectRows.push(temp);
                                isFound = true;
                                var parent = this.childToParentMap.get(temp);
                                if(parent != null){
                                    expandRows.push(parent);
                                }
                            }
                        }
                    }
                    if(!isFound){
                        for (let temp of this.atc3ToATC4Map.keys()) {
                            var tempExp = this.createRegExp(temp);
                            var result = atcOTCCode.match(tempExp);
                            if(result != null) {
                                selectRows.push(temp);
                                isFound = true;
                                var parent1 = this.childToParentMap.get(temp);
                                if(parent1 != null){
                                    expandRows.push(parent1);
                                    var parent2 = this.childToParentMap.get(parent1);
                                    if(parent2 != null){
                                        expandRows.push(parent2);
                                        var parent2 = this.childToParentMap.get(parent1);
                                    }
                                }
                            }
                        }
                    }
                    if(!isFound){
                        for (let temp of this.atcToMarketShareMap.keys()) {
                            var tempExp = this.createRegExp(temp);
                            var result = atcOTCCode.match(tempExp);
                            if(result != null) {
                                selectRows.push(temp);
                                isFound = true;
                                var parent1 = this.childToParentMap.get(temp);
                                if(parent1 != null){
                                    expandRows.push(parent1);
                                    var parent2 = this.childToParentMap.get(parent1);
                                    if(parent2 != null){
                                        expandRows.push(parent2);
                                        var parent3 = this.childToParentMap.get(parent2);
                                        if(parent3 != null){
                                            expandRows.push(parent3);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(!isFound){
                        notFoundCodeList.add(atcOTCCode);
                    }
                })
            }
            else{
                this.showToast("Error", "error", "Please enter some ATC/OTC codes first!!!");
            }
            if(notFoundCodeList.size > 0){
                this.showNotFoundVisible = true;
            }else{
                this.showNotFoundVisible = false;
            }
            this.showNotFoundCodes = notFoundCodeList;
            
            if(expandRows.length > 0){
                this.expandedRows = expandRows;
            }
            if(selectRows.length > 0){
                this.selectedRows = selectRows;
                this.showSelectedVisible = true;
                this.showSelectedRows = selectRows;
            }
        }
    }

    createRegExp(tempName){
        var fetchCode = tempName.split(" ");
        var tempCode = fetchCode[0];
        var tempExp = new RegExp('^'+tempCode+'$');
        return tempExp;
    }
	
    handleClear(){
        var emptyList =[];
        this.selectedRows = emptyList;
        this.expandedRows = emptyList;
        this.showSelectedVisible = false;
        this.showSelectedRows = emptyList;
        this.totalMarketShare = 0.00;
    }
    getBykey(map, searchKey) {
        for (let [key, value] of map.entries()) {
          if (key === searchKey)
            return value;
        }
    }
}
 
