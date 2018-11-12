# Exercise 03 - Testing your apps in production

# Test 1: Checking errors on production

1. Create a test that checks that the page loads as expected without errors
1. Run the test against production environment. This test should pass
1. Access to the production environment, and introduce an invalid javascript code as script in the RAW HTML area
1. Run the test again. This test should fail.
1. Create a Kubernetes cronjob so this test is run in a daily basis
