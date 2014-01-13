$.getJSON(window.location.pathname, function( data ) {
  new Morris.Line({
    element: 'myfirstchart',
    data: data,
    xkey: 'month',
    ykeys: ['views'],
    labels: ['Visninger']
  });
});
