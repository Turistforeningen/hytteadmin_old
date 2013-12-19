module.exports = function (selected, options) {
  var opts = [
    'CC BY 3.0 NO',
    'CC BY-NC 3.0 NO',
    'CC BY-ND 3.0 NO',
    'CC BY-SA 3.0 NO',
    'CC BY-NC-ND 3.0 NO',
    'CC BY-NC-SA 3.0 NO'
  ]

  res = ['<select class="form-control" name="lisens" id="{{id}}">']
  for (var i = 0; i < opts.length; i++) {
    res.push('<option' + (selected == opts[i] ? ' selected' : '') + '>' + opts[i] + '</option>')
  }
  res.push('</select>')

  return res.join(' ')
};

