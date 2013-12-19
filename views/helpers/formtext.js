module.exports = function (name, id, rows, options) {
  return '<textarea ' + [
    'class="form-control"',
    'name="' + name + '"',
    'id="' + id + '"',
    'rows="' + rows + '"'
  ].join(' ') + '>' + options.fn(this) + '</textarea>'
};

