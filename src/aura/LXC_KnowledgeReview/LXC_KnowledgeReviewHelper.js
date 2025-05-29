({
	showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    },
})