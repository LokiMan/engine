module.exports = function () {
  return {
    files: [
      '**/*.coffee',
      '!test/**/*.test.coffee',
      '!node_modules/**/*.*',
      '!dev-server/node_modules/**/*.*'
    ],

    tests: [
      'test/**/*.test.coffee'
    ],

    env: {
      type: 'node'
    },

    testFramework: "mocha",

    setup: function () {
      global.expect = require('chai').expect;
    }
  };
};
