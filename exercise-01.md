# Exercise 01 - Testing apps on K8s

On K8s, using more than one cluster is a common practice when running services on production. For instance, a common scenario could be composed by 2 clusters:

- Staging cluster, for testing purposes.
- Production cluster, only for running servers on production.

In this workshop, we'll use Minikube. Therefore, we can't use reproduce such scenario. As an alternative, different namespaces will be used for each environment:

- Namespace `staging` will be used to launch a battery of tests on apps running on K8s.
- Namespace `production` will be used to run our apps once they have been tested.

## Pre-requisites

To setup the scenario used on this workshop, we need to:

- Install/Start Minikube.
- Install/Configure Kubectl.
- Install/Configure/Initialize Helm.
- Create the namespaces `production` & `staging`.

Bash scripts to do so on Linux/MacOS are provided at [scripts](./scripts) directory. For instance, run the command below to setup your scenario on Linux:

```bash
$ ./resources/setup-linux.bash
```

## Application used

The CMS below will be used as application to be tested on K8s:

- [https://github.com/fjagugar/blog-example](https://github.com/fjagugar/blog-example)

As you can check, it's a simple Node.js application which requires MongoDB as database. To deploy this application on K8s, the [Bitnami Node Chart](https://github.com/bitnami/charts/tree/master/bitnami/node) will be deployed using Helm.

## Steps to test an app on K8s

A common workflow on a CI/CD pipeline to deploy to production is:

- Deploying the app on `staging`.
- Run a battery of tests.
- Deploying the app on `production`.
- Run a second battery of tests (minimal testing only)

### Deploying the app on staging

Use the command below to configure kubectl to use the `staging` namespace:

```bash
$ kubectl config set-context "$(kubectl config current-context)" --namespace=staging
```

Two steps are needed to deploy the app on K8s:

- Create a YAML file with the list of parameters to set when deploying the chart. Consult the [Configuration parameters available](https://github.com/bitnami/charts/tree/master/bitnami/node#configuration) in the chart.
  - Two **INCOMPLETE** files are provided at [resources](./resources) directory to help you with that.
- Deploy the chart using the YAML file. You can use the command below to do so:

```bash
$ helm install bitnami/node --name "cms-staging" -f "$(git rev-parse --show-toplevel)/resources/values-staging.yaml"
```

- Wait until the deployment is ready using the command below:

```bash
$ kubectl get deploy cms-staging-node --watch
```

- Configure admin user:

```bash
$ echo "12345" | kubectl exec -i "$(kubectl get pods -l app=node,release=cms-staging -o jsonpath='{.items[0].metadata.name}')" -- node app.js apostrophe-users:add admin admin
```

### Run a battery of tests

To test the app, a K8s job will be used. This job will create a pod which will run the battery of tests and will report the testing result.

To create this K8s job, it's necessary to:

- Create a Docker Image for the pod used on the job. Under the directory [testing-job/docker-image](./testing-job/docker-image) you'll find a **Dockerfile** that can be used to do so.

>  Note: The image uses some the tests available under the directories [testing-job/docker-image/test/verification](./testing-job/docker-image/test/verification) and [testing-job/docker-image/test/functional](./testing-job/docker-image/test/functional). On this exercise, we'll only used the ones under the verification folder which uses Mocha to do some basic testing on the app.

- Complete the test `testing-job/docker-image/test/verification/common-tests.js` to practise with Mocha.
- Use the command below to create the image:

```bash
$ eval $(minikube docker-env)
$ cd "$(git rev-parse --show-toplevel)/testing-job/docker-image"
$ docker build . -t testing-image:1.0.0
```

- Create the K8s job definition. Use the skeletons provided under the directory [testing-job/definitions](./testing-job/definitions) to do so.

> Note: Check [official docs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) fore more information about Jobs definitions.

- Launch the job to test the application and wait for the results:

```bash
$ kubectl create -f "$(git rev-parse --show-toplevel)/testing-job/definitions/job-staging.yaml"
```

- Delete the job

### Deploying the app on production

Use the command below to configure kubectl to use the `production` namespace:

```bash
$ kubectl config set-context "$(kubectl config current-context)" --namespace=production
```

- Once the app has successfully passed the battery of tests, deploy it to production:

```bash
$ helm install bitnami/node --name "cms-production" -f "$(git rev-parse --show-toplevel)/resources/values-production.yaml"
```

- Wait until the deployment is ready using the command below:

```bash
$ kubectl get deploy cms-production-node --watch
```

- Configure admin user:

```bash
$ echo "12345" | kubectl exec -i "$(kubectl get pods -l app=node,release=cms-production -o jsonpath='{.items[0].metadata.name}')" -- node app.js apostrophe-users:add admin admin
```

- Launch the job to test the application on production and wait for the results:

```bash
$ kubectl create -f "$(git rev-parse --show-toplevel)/testing-job/definitions/job-production.yaml"
```

- Delete the job

### Other resources

Scripts to automatically deploy the application and running the tests are provided under the [scripts](./scripts) directory.
