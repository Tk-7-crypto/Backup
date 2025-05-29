({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
    	$A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
		if( !$A.util.isEmpty(component.get('v.value')) ) {
			helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
		}
	},

    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        //event.preventDefault();
      // console.log('Key',event.key);
        // console.log('Key',event.getParams().keyCode);
       // console.log('Anykey',event.which);
        if(event.which == 13){
            //event.cancelBubble = true;
           //  return false;
           event.preventDefault();
}
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            // if(event.getParams().keyCode == 13){
            
             // event.cancelBubble = true;
            console.log("enter was pressed");
        
    //return false;
        //  }
		    helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
          //if(event.getParams().keyCode == 13){
           // event.preventDefault();
           // event.cancelBubble = true;
            console.log("enter was pressed");
        
   //return false;
        //  }
	},

    // When an item is selected
	selectItem : function( component, event, helper ) {
        // event.preventDefault();
        if(!$A.util.isEmpty(event.currentTarget.id)) {
    		var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(function (x) {return x.value===event.currentTarget.id});
                //recordsList.findIndex(function (x) {return x.value;} === event.currentTarget.id)
            
    		//var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            console.log('selectedRecord = ',component.get('v.selectedRecord'));
            component.set('v.value',selectedRecord.value);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
            var cmpEvent = component.getEvent("sampleCmpEvent"); 
            cmpEvent.setParams({
            "message" : selectedRecord.label });
            cmpEvent.fire();
        }
	},

    // To remove the selected item.
	removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },

    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
    	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})