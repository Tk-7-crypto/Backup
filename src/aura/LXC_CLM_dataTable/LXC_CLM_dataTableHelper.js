({
	setupTable: function (component, data) {
		var cols = component.get("v.columns"),
			data = component.get("v.data");
		this.setupColumns(component, cols);
		this.setupData(component, data);
		component.set("v.isLoading", false);
	},
	setupColumns: function (component, cols) {
		var tempCols = [];
		if (cols) {
			cols.forEach(function (col) {
				col.thClassName = "slds-truncate";
				col.thClassName += col.sortable === true ? " slds-is-sortable" : "";
				col.thClassName += col.resizable === true ? " slds-is-resizable" : "";
				if (col.sortable === true) {
					col.sortBy = col.fieldName;
					if (col.type === "url" && col.attributes && typeof col.attributes.label === "object")
						col.sortBy = col.attributes.label.fieldName;
				}
				tempCols.push(col);
			});
			component.set("v.columns", JSON.parse(JSON.stringify(tempCols)));
		}
	},
	setupData: function (component, data) {
		var tableData = [],
			cols = component.get("v.columns");
		component.set("v.dataCache", JSON.parse(JSON.stringify(data)));
		if (data) {
			data.forEach(function (value, index) {
				var row = {},
					fields = [];
				cols.forEach(function (col) {
					var field = {};
					field.name = col.fieldName;
					field.value = value[col.fieldName];
					field.type = col.type ? col.type : "text";
					if (field.type === "percent") {
						field.isViewSpecialType = true;
						if (col.attributes) {
							field.formatter = col.attributes.formatter;
							field.style = col.attributes.formatter;
							field.minimumFractionDigits = col.attributes.minimumFractionDigits ? col.attributes.minimumFractionDigits : 2;
							field.maximumFractionDigits = col.attributes.maximumFractionDigits ? col.attributes.maximumFractionDigits : 2;
							field.currencyCode = col.attributes.currencyCode ? col.attributes.currencyCode : "USD";
						}
					}
					if (field.type === "currency") {
						field.isViewSpecialType = true;
					}
					if (field.type === "date") {
						field.isViewSpecialType = true;
					}
					if (field.type === "number") {
						field.isViewSpecialType = true;
						if (col.attributes) {
							field.formatter = col.attributes.formatter;
							field.style = col.attributes.formatter;
							field.minimumFractionDigits = col.attributes.minimumFractionDigits ? col.attributes.minimumFractionDigits : 0;
							field.maximumFractionDigits = col.attributes.maximumFractionDigits ? col.attributes.maximumFractionDigits : 2;
							field.currencyCode = col.attributes.currencyCode ? col.attributes.currencyCode : "USD";
						}
					}
					if (field.type === "picklist") {
						field.isEditSpecialType = true;
						field.selectOptions = col.selectOptions;
					}
					if (field.type === "link") {
						field.isViewSpecialType = true;
						if (col.attributes) {
							if (typeof col.attributes.label === "object")
								field.label = value[col.attributes.label.fieldName];
							else
								field.label = col.attributes.label;
							if (typeof col.attributes.title === "object")
								field.title = value[col.attributes.title.fieldName];
							else
								field.title = col.attributes.title;
							if (col.attributes.actionName) {
								field.type = "link-action";
								field.actionName = col.attributes.actionName;
							}
							field.target = col.attributes.target;
						}
					}
					field.editable = col.editable ? col.editable : false;
					field.tdClassName = field.editable === true ? "slds-cell-edit" : "";
					field.mode = "view";
					fields.push(field);
				});
				row.id = value.Id;
				row.fields = fields;
				tableData.push(row);
			});
			component.set("v.tableData", tableData);
			component.set("v.tableDataOriginal", JSON.parse(JSON.stringify(tableData)));
			component.set("v.updatedTableData", JSON.parse(JSON.stringify(tableData)));
		}
	},
	updateTable: function (component, rowIndex, colIndex, value) {
		var data = component.get("v.tableData");
		data[rowIndex].fields[colIndex].value = value;
		component.set("v.tableData", data);
		//Update Displayed Data Cache
		var updatedData = component.get("v.updatedTableData");
		updatedData[rowIndex].fields[colIndex].value = value;
		updatedData[rowIndex].fields[colIndex].mode = "view";
		component.set("v.updatedTableData", updatedData);
		//Update modified records which will be used to update corresponding salesforce records
		var newList = [];
		var records = component.get("v.modifiedRecords");
		var recIndex = records.findIndex((rec) => rec.id === data[rowIndex].id);
		if (recIndex !== -1) {
			records[recIndex]["" + data[rowIndex].fields[colIndex].name] = value;
		} else {
			var obj = {};
			obj["id"] = data[rowIndex].id;
			obj["" + data[rowIndex].fields[colIndex].name] = value;
			records.push(obj);
		}
		component.set("v.modifiedRecords", records);
		var dataCache = component.get("v.dataCache");
		var recIndex = dataCache.findIndex((rec) => rec.Id === data[rowIndex].id);
		var fieldName = data[rowIndex].fields[colIndex].name;
		dataCache[recIndex][fieldName] = value;
		component.set("v.dataCache", dataCache);
	},
});