casper.options.viewportSize = {width: 1280, height: 639};

const testingMode = process.env.TESTING_MODE;
const httpUrl = 'http://cms-' + testingMode + '-node:3000'

casper.test.begin('Login Test', function(test) {
  casper.start(httpUrl);

  // Replace '#######'
  casper.waitForText('#######', function() {
    this.test.assertTextExists('#######', '"#######" text appears');
    this.capture('#######.png');
  });

  /* Fill this step
  /
  / Using waitUntilVisible click on Login
  /
  */

  casper.waitUntilVisible('form[action="/login"]', function() {
    this.test.assertVisible('form[action="/login"]', 'Form is visible. Filling...');
    this.capture('formEmpty.png');
    /* Fill this part
    /
    / Fill form fields
    /
    */
    this.capture('formFilled.png');
    /* Fill this part
    /
    / Click on Login (submit form)
    /
    */
    this.test.assertVisible('input[value="Log In"]', 'Log In button is visible. Clicking...');
    this.click('input[value="Log In"]');
  });

  // Replace '#######'
  casper.waitForText('#######', function() {
    this.test.assertTextExists('#######', 'Logged in successfully!');
    this.capture('#######.png');
  });

  casper.run();
});
