({
	setProductRecordToCurrentLayer: function(component, event, helper, currentLayer, productRecords) {
       if(currentLayer == '2') {
           component.set("v.LayerTwo", productRecords);
           var layerComp = component.find("LayerTwo");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerThree", []);
           component.set("v.LayerFour", []);
           component.set("v.LayerFive", []);
           component.set("v.LayerSix", []);
           component.set("v.LayerSeven", []);
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '3') {
           component.set("v.LayerThree", productRecords);
           var layerComp = component.find("LayerThree");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerFour", []);
           component.set("v.LayerFive", []);
           component.set("v.LayerSix", []);
           component.set("v.LayerSeven", []);
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '4') {
           component.set("v.LayerFour", productRecords);
           var layerComp = component.find("LayerFour");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerFive", []);
           component.set("v.LayerSix", []);
           component.set("v.LayerSeven", []);
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '5') {
           component.set("v.LayerFive", productRecords);
           var layerComp = component.find("LayerFive");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerSix", []);
           component.set("v.LayerSeven", []);
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '6') {
           component.set("v.LayerSix", productRecords);
           var layerComp = component.find("LayerSix");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerSeven", []);
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '7') {
           component.set("v.LayerSeven", productRecords);
           var layerComp = component.find("LayerSeven");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
           component.set("v.LayerEight", []);
       }
       else if(currentLayer == '8') {
           component.set("v.LayerEight", productRecords);
           var layerComp = component.find("LayerEight");
           if(layerComp != undefined) {
               layerComp.set("v.enableRegionalHierarchy", false);
           }
       }
    }
})