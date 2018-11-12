# Exercise 02 - Testing your apps with CasperJS

## Test 1: Login test

1. Access to main page
1. Click on “Login”
1. Introduce User and Password
1. Click Login

The resulting page should be the administration page

## Test 2: Adding some text to the page

1. Access to admin page as authenticated user
1. Click on first text area
1. Introduce some text
1. Click outside the text area

The introduced text should be stored in the database.

1. Access to the main page as unauthenticated user

The content introduced should appear in the page

## Test 3: Adding some HTML content

1. Access to admin page as authenticated user
1. Click on raw HTML area
1. Introduce some HTML text
1. Click outside the text area

The HTML introduced should be interpreted as expected by the website.
