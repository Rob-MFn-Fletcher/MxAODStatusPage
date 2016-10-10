
// This function turns on the fixed menu bar. It also allows it to show the
// header if you are scrolled to the top of the page.
var scrolling = function(){
    //Calculate the height of <header>
    //Use outerHeight() instead of height() if have padding
    var aboveHeight = $('#jumbotron').height();

//when scroll
    $(window).scroll(function(){
        //if scrolled down more than the header’s height
            if ($(window).scrollTop() > aboveHeight){
        // if yes, add “fixed” class to the <nav>
        // add padding top to the #content
            //(value is same as the height of the nav)
            $('nav').addClass('navbar-fixed-top').css('top','0').next()
            .css('padding-top','60px');
            } else {
        // when scroll up or less than aboveHeight,
        //    remove the “fixed” class, and the padding-top
            $('nav').removeClass('navbar-fixed-top').next()
            .css('padding-top','0');
            }
        });
};

// Get the Htags that should be in the drop down menu. Call a PHP script
// that lists all directories in variables/htags.
var fillHTags = function(){
    $.ajax({
        url: '../php/getHtags.php',
        type: 'get',
        success: function(htags_json){
            //Put the li elements in the menu
            var htags_array = JSON.parse(htags_json);
            console.log("Success: Got Htags from server")
            console.log("".stringify(htags_array, null, 2));
            $('#htags-dropdown').removeElementById('default'); // remove the default li item.
            for( var htag in htags_array){   // Add each element in the array to the ul.
                var menuText = $.createTextNode(htag);
                var menuItem = $.createElement('li');
                menuItem.appendChild(menuText);
                $('#htags-dropdown').appendChild(menuItem);
            }
        };,
        failure: function(){
            console.log("Failed to get the htags")
        }
    });
};

$(document).ready(function() {
    scrolling();
    fillHTags();
});
