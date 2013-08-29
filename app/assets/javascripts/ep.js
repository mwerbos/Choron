// Script for nice expected profit display.

function toggleEP() {
  if( $("table.expected-profit").css('display')==='none' ) {
    // Expected profit is not displayed, toggle it on
    $("table.expected-profit").css('display','inline');
    // make option to hide it
    $('#expected-profit-breakdown').text('hide breakdown');
  } else {
    // Expected profit is displayed, toggle it off
    $("table.expected-profit").css('display','none');
    // bring back the option to show it again
    $('#expected-profit-breakdown').text('show breakdown');
  }
}
