$(document).ready(function() {
  $('#event-search-form').submit(function(event) {
    event.preventDefault();
    var searchValue = $('#search_location').val();

    $.getScript('/all_events/?search_location=' + searchValue);
    $('#search_location').val("");
  });

  $('#near-me-button').click(function(event) {
    event.preventDefault();
    navigator.geolocation.getCurrentPosition(function(position){
      var latitude = position.coords.latitude;
      var longitude = position.coords.longitude;  
    $.getScript('/all_events?latitude=' + latitude + '&longitude=' + longitude);
    });

  });
});