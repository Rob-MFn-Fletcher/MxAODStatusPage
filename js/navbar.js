
// This function turns on the fixed menu bar. It also allows it to show the
// header if you are scrolled to the top of the page.
var scrolling = function(){
    //Calculate the height of <header>
    //Use outerHeight() instead of height() if have padding
    var aboveHeight = $('#jumbotron').outerHeight();
    var navHeight = $('nav').outerHeight(true);

//when scroll
    $(window).scroll(function(){
        //if scrolled down more than the header’s height
            if ($(window).scrollTop() > aboveHeight){
        // if yes, add “fixed” class to the <nav>
        // add padding top to the #content
            //(value is same as the height of the nav)
            $('nav').addClass('navbar-fixed-top').css('top','0').next()
            .css('padding-top',navHeight);
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
        url: 'php/getHtags.php',
        type: 'get',
        success: function(htags_json){
            //Put the li elements in the menu
            var htags_array = JSON.parse(htags_json);
            console.log("Success: Got Htags from server")
            console.log(JSON.stringify(htags_array, null, 2));
            $('#default-htags').remove(); // remove the default li item.
            for( var htag in htags_array){   // Add each element in the array to the ul.
                $('#htags-dropdown').append('<li><a href="'+'#'+'">'+htags_array[htag]+'</a></li>');
            }                              // link goes here ^
        },
        failure: function(){
            console.log("Failed to get the htags")
        }
    });
};

var getHtagContent = function(){
    $('#htags-dropdown li').click(function(){
        var selectedTag = $(this).text();
    })
};

$(document).ready(function() {
    scrolling();
    fillHTags();
    $(document).click(function(){
      $("#livesearch").hide();
    });
});
