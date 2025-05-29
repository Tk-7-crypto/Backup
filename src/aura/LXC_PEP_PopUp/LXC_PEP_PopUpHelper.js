({
    getCookie: function(component,cookieName)
    {
        console.log('inside get Cookie');
        var dc = document.cookie;
        console.log('dc cookie : ' + dc);        
        var prefix = cookieName;
        var begin = dc.indexOf("; " + prefix);
        if (begin == -1) {
            begin = dc.indexOf(prefix);
            if (begin != 0) component.set("v.isModalOpen", true);
        }
        else
        {
            console.log('inside else ')
            begin += 2;
            var end = document.cookie.indexOf(";", begin);
            if (end == -1) {
                end = dc.length;
            }
        }
        // return decodeURI(dc.substring(begin + prefix.length, end));
        console.log('URI : ' + decodeURI(dc.substring(begin + prefix.length, end)));
    },
    
    setCookie: function(component,event, helper, numberOfDays)
    {
        console.log('inside set cookie ');
        var cookieName = component.get("v.pageName");
        var d = new Date();
        // d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000)); //to expire cookie after 1 year
        d.setTime(d.getTime() + (numberOfDays * 24 * 60 * 60 * 1000)); // to expire cookie before expiration date
        var expires = "expires=" + d.toUTCString();
        console.log('cookie expiration date : ' + d.toUTCString());
        document.cookie = cookieName +"=visited;" + expires + ";path=/";
        console.log('New cookie : ' + document.cookie);
    }
})