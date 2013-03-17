function get_variables() {
    var variables = {};
    var components = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(match, key, value) {
        variables[key] = value;
    });
    return variables;
}

var current_pane = -1;

function switch_pane(pane_index) {

    if (current_pane == pane_index) {
        return;
    }

    // validate pane selection

    // get pane data
    var panes = $('#sidebar > .sidebar-item');

    // hide all panes
    panes.find('a').removeClass('current');

    // show current pane
    var current = panes.eq(pane_index);
    current.find('a').addClass('current');
    var source = current.find('a').data('source');
    var page_title = current.find('a').text();

    $.ajax({
        url: path_for_source(source)
    }).done(function(data) {
        $('#content').html(data);
    });

    // add new pane to history
    if (current_pane != pane_index) {
        var state_object = { page: pane_index };
        history.pushState(state_object, main_title + " - " + page_title, "index.html?pane=" + pane_index);
        state_pane = pane_index;
    }
    current_pane = pane_index;

    document.title = main_title + ' > ' + page_title;

}

function pane_count() {
    return $('#sidebar > .sidebar-item').length;
}

var total_panes = 0;

function path_for_source(source) {
    return 'pages/' + source.replace(/\.md/, '.html');
}

document.onkeydown = function(e) {
    var key = document.all ? window.event.keyCode
            : e.keyCode;

    var next_pane = current_pane;
    if (key == '40') { // down arrow
        next_pane = (current_pane + 1) % total_panes;
    } else if (key == '38') { // up arrow
        next_pane = (current_pane - 1);
        if (next_pane < 0) {
            next_pane = total_panes - 1;
        }
    }

    switch_pane(next_pane);
}

$(document).ready(function() {
    total_panes = pane_count();
    var variables = get_variables();

    var first_pane = 0
    if (variables['pane']) {
        first_pane = variables['pane'];
    }
    switch_pane(first_pane);

    $('#sidebar > .sidebar-item a').on('click', function(event) {
        var pane_index = $.inArray(this, $('#sidebar > .sidebar-item').find('a'));
        switch_pane(pane_index);
    });
});

window.onpopstate = function(event) {
    if (event.state) {
        switch_pane(event.state.page);
    } else {
        //switch_pane(get_variables()['pane']);
    }
}


