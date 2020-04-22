module.exports = {
  timeout: 1000,
  reporter: 'spec',
  recursive: true,
  require: ['coffeescript/register', 'test/init.coffee'],
  spec: 'test/**/*.test.coffee',
};
