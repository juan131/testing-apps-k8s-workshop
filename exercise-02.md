# Exercise 02 - Testing your apps with CasperJS

Under the [testing-job/docker-image/test/functional](./testing-job/docker-image/test/functional) directory you can find two templates to write some functional tests.

## Tests

### 1.- Login

This test consist on navigate to the initial page, click on login, fill the form using the user/password set in your app, submit the form and check that you are logged in properly.

> NOTE: It is important to check when the test fails. What happens when you enter a wrong password?

### 2.- Click on a menu

Reusing the login part, you should create a new test to check that the application works as expected and you can navigate in the menu.

Using the provided templates, you should implement those tests to ensure that our application is working from a functional point of view.

## Tips

- Try to use unique and invariable selectors.
- `waitForSelector` or `waitUntilVisible`?
- Everything is [here](http://docs.casperjs.org/en/latest/modules/casper.html) and [here](http://docs.casperjs.org/en/latest/modules/tester.html) (CasperJS documentation)

## Fast checking

- Go to the blog example ([https://github.com/fjagugar/blog-example](https://github.com/fjagugar/blog-example)) and modify `docker-compose.yaml` adding the `test` service:

```yaml
mongodb:
  image: 'bitnami/mongodb:latest'

## Add this section
test:
  image: 'test-image:latest'
  command: sh -c 'tail -f /dev/null'

node:
  tty: true # Enables debugging capabilities when attached to this container.
  image: 'bitnami/node:latest'
```

- Build `test-image`:

```bash
cd testing-job/docker-image
docker build . -t test-image:latest
```

- Deploy the cluster (in the blog-example directory):

```bash
docker-compose up
```

- Connect to the `test` container:

```bash
docker ps
docker exec -it TEST_CONTAINER_ID bash
```

- Once inside the container, modify tests files using

```javascript
casper.start('http://node:300');
```

instad of

```javascript
casper.start(httpUrl);
```

at the beginning of the tests

- Run CasperJS tests manually

```bash
/test/node_modules/.bin/casperjs test /test/functional/TEST.js
```
