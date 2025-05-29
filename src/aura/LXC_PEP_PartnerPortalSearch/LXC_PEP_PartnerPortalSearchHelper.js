({
    searchFor : function(component) {
        var searchText = component.find('enter-search').get('v.value');
        var limit = component.get("v.limit");
        sessionStorage.setItem('search--text',searchText);
        var action = component.get('c.searchForIds');
        action.setParams({ searchText: searchText,
            searchObject: '',
            rowLimit: limit,
            rowOffset: 0});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {                
                var results = response.getReturnValue();
                console.log('In Success ===================' + JSON.stringify(results));
                sessionStorage.setItem('customSearch--results', JSON.stringify(results));
                var navEvt = $A.get('e.force:navigateToURL');
                navEvt.setParams({ url: '/search-results' });
                navEvt.fire();
            }else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        sessionStorage.setItem('localTransfer','');
    }
})
