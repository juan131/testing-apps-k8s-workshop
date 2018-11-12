'use strict';

// Node modules
const chai = require('chai');
const expect = chai.expect;
const chaiHttp = require('chai-http');
chai.use(chaiHttp);

/* Fill this part
/
/ It should setup the URL to verify based on env. variables
/
// const testingMode = ...
// const httpUrl = ...
*/

describe('HTTP Endpoint Verification Tests', () => {
  it('Should return statusCode 200', () => {
    chai.request(httpUrl)
    .get('/')
    .end(function (err, res) {
      /* Fill this part
      /
      / It should check there are no errors and the status is 200
      /
      */
    })
  });
});
