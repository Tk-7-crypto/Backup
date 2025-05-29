({
    fetchData: function(component){
        var folders = component.get('v.folders').join(",");
        var numberOfRecords = component.get('v.numberOfRecords');
        var jsonData = JSON.stringify({
            recordId: component.get('v.recordId'),
            numberOfRecords: numberOfRecords + 1,
            folderName: folders
        });

        this.callServer(component, "c.initData", function(response) {
            var jsonData = JSON.parse(response);
            
            const {
                records
            } = jsonData;
            
            if((numberOfRecords != -1) && (records.length > numberOfRecords)) {
                records.pop();
                component.set('v.numberOfRecordsForTitle', numberOfRecords + '+');
            } else {
                component.set('v.numberOfRecordsForTitle', Math.min(numberOfRecords, records.length));
            }
        }, {
            jsonData: jsonData
        });
    }
})