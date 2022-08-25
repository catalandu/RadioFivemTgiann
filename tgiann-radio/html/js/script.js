var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();   
});


window.addEventListener('message', function(event) {
    if (event.data.type == "enableui") {
        document.body.style.display = event.data.enable ? "block" : "none";
    }
});

document.onkeyup = function (data) {
    if (data.which == 27) { // Escape key
        $.post('https://tgiann-radio/escape', JSON.stringify({}));
    }
};

$("#login-form").submit(function(e) {
    e.preventDefault();
    $.post('https://tgiann-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$('#onoff').click(function (event, ui) {
    event.preventDefault();
    $.post('https://tgiann-radio/leaveRadio', JSON.stringify({}));
    tooltipHover()
});

$('#kis').click(function (event, ui) {
    event.preventDefault();
    $.post('https://tgiann-radio/seskis', JSON.stringify({}));
    tooltipHover()
});

$('#ac').click(function (event, ui) {
    event.preventDefault();
    $.post('https://tgiann-radio/sesac', JSON.stringify({}));
    tooltipHover()
});

function tooltipHover() {
    $("[data-toggle='tooltip']").tooltip('hide');
};
