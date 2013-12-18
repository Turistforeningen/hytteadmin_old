module.exports = function (context, options) {
  console.log('glob', arguments);
  return options.fn([{name: 'foo'}, {name: 'bar'}]);
};
