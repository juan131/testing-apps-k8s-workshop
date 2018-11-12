'use strict';

// Node modules
const chai = require('chai');
const expect = chai.expect;
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Mongo URL
const testingMode = process.env.TESTING_MODE;
const mongoUrl = `mongodb://user:secret_password@cms-${testingMode}-mongodb:27017/cms_db`

// Create a new schema that accepts a 'name' object.
// 'name' is a required field
const testSchema = new Schema({
  name: { type: String, required: true }
});

// Create a new collection called 'TestingCollection'
const testingCollection = mongoose.model('TestingCollection', testSchema);

describe('Database Tests', function() {
  // Before starting the test, create a sandboxed database connection
  // Once a connection is established invoke done()
  before(function (done) {
    mongoose.connect(mongoUrl, { useNewUrlParser: true });
    const db = mongoose.connection;
    db.on('error', console.error.bind(console, 'connection error'));
    db.once('open', function() {
      done();
    });
  });

  describe('Test Database', function() {
    // Save object with 'name' value of 'Juan'
    it('New name saved to test database', function(done) {
      const testName = testingCollection({
        name: 'Juan'
      });

      testName.save(done);
    });
    it('Dont save incorrect format to database', function(done) {
      // Attempt to save with wrong info. An error should trigger
      const wrongSave = testingCollection({
        notName: 'Not Juan'
      });
      wrongSave.save(err => {
        if(err) { return done(); }
        throw new Error('Should generate error!');
      });
    });
    it('Should retrieve data from test database', function(done) {
      // Look up the 'Juan' object previously saved.
      testingCollection.find({name: 'Juan'}, (err, name) => {
        if(err) {throw err;}
        if(name.length === 0) {throw new Error('No data!');}
        done();
      });
    });
  });
  // After all tests are finished, drop collection and close connection
  after(function(done){
    mongoose.connection.db.dropCollection('TestingCollection', function() {
      mongoose.connection.close(done);
    });
  });
});
