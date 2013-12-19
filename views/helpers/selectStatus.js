module.exports = function (selected, options) {
  var opts = [
    'Offentlig',
    'Privat',
    'Kladd'
  ]

  res = ['<select class="form-control" name="status" id="{{id}}">']
  for (var i = 0; i < opts.length; i++) {
    res.push('<option' + (selected == opts[i] ? ' selected' : '') + '>' + opts[i] + '</option>')
  }
  res.push('</select>')

  return res.join(' ')
};

