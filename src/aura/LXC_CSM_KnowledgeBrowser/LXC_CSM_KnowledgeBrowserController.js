({
    doInit: function(component, event, helper) {
        helper.getProducts(component);
    },
    filteredProducts: function(component, event, helper) {
        component.set("v.isLoading", true);
        var filteredString=event.getSource().get("v.value");
        var filteredProducts=[];
        var products=component.get("v.products");
        if(filteredString !=""){
            for(var i=0;i < products.length; i++){
                if (products[i].Name.toUpperCase().indexOf(filteredString.toUpperCase()) > -1){
                    filteredProducts.push(products[i]);
                }
            }
            component.set("v.filteredProducts",filteredProducts);
        }else{
            component.set("v.filteredProducts",products);
        }
        component.set("v.isLoading", false);
    },
    filteredArticles: function(component, event, helper) {
        component.set("v.isLoading", true);
        var filteredString=event.getSource().get("v.value");
        var filteredArticleObj=[];
        var articleObj=component.get("v.articleObj");
        var categorization=[];
        if(filteredString !=""){
            for(var c=0;c < articleObj.length; c++){
                var filteredArticles=[];
                var articleCat = articleObj[c];
                var articles = articleCat.articles;
                for(var i=0;i < Object.keys(articles).length; i++){
                    if (articles[i].Title.toUpperCase().indexOf(filteredString.toUpperCase()) > -1){
                        filteredArticles.push(articles[i]);
                    }
                }
                filteredArticleObj.push({
                    categorization: articleObj[c].categorization,
                    articles: filteredArticles
                });
            }
            component.set("v.filteredArticleObj",filteredArticleObj);
        }else{
            component.set("v.filteredArticleObj",articleObj);
        }
        component.set("v.isLoading", false);
    },
    productClick: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var productName = ctarget.dataset.title;  
        component.set("v.productName",productName);
        helper.getArtclesByProductName(component,productName,"");
        helper.getAccountsArticlesByProductName(component,productName);
    },
    openRecord:function(component,event,helper){
        var ctarget = event.currentTarget;
        var recordId = ctarget.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    showMore: function(component, event, helper) {
        component.set("v.numChapter",parseInt(event.currentTarget.dataset.chapter_num));
        component.set("v.filteredArticleObj", component.get("v.filteredArticleObj"));
    },

    back: function(component, event, helper) {
        component.set("v.numChapter",-1)
        component.set("v.filteredArticleObj", component.get("v.filteredArticleObj"));
    },

    selectedAccount: function (component, event, helper) {
        var accId = component.find('accountId').get('v.value');
        var productName = component.get("v.productName");
        helper.getArtclesByProductName(component,productName,accId);
    }
})