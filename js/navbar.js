$(document).ready(function() {

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
    });
