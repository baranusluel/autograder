$(document).ready(function() {
    // Find div (modFunctions), parse
    var funs = $('#modFunctions').children();
    funs.each(function(index) {
        // Create the pill
        var item = $('<li></li>');
        item.addClass('nav-item');
        var link = $('<a></a>');
        link.addClass('nav-link');
        link.attr('href', './' + $(this).attr('data-link'));
        link.text($(this).text());
        item.append(link);
        $('#modFunctions').append(item);
        $(this).remove();
    });
});