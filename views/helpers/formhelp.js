module.exports = function (width, options) {
  return [
    '</div><div class="col-sm-' + width + '">',
    '<span class="help-block">' + options.fn(this) + '</span>'
  ].join('')
};

