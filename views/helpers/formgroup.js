module.exports = function (name, width, options) {
  if (typeof width === 'undefined') {
    throw new Error('formgroup helper expects at name')
  }
  if (typeof options === 'undefined') {
    options = width;
    width = 10;
  }

  this.id = name.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase()

  return [
    '<div class="form-group">',
    '<label for="' + this.id + '" class="col-sm-2 control-label">',
    name,
    '</label>',
    '<div class="col-sm-' + width + '">',
    options.fn(this),
    '</div></div>'
  ].join('')

};

