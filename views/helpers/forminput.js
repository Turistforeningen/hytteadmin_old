module.exports = function (name, id, type, placeholder, options) {
  return '<input ' + [
    'class="form-control"',
    'type="' + type  + '"',
    'id="' + id + '"',
    'placeholder="' + placeholder + '"',
    'value="' + options.fn(this) + '"'
  ].join(' ') + '>'
};

