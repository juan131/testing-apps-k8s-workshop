casper.options.viewportSize = {width: 1280, height: 639};

const testingMode = process.env.TESTING_MODE;
const httpUrl = 'http://cms-' + testingMode + '-node:3000'

casper.test.begin('Click Page Menu Test', function(test) {
  casper.start(httpUrl);

  /* Fill this step
  /
  / Copy your login solution
  /
  */

  /* Fill this step
  /
  / Click on "Page Menu" and check that all items are showed
  /
  */

  casper.run();
});
