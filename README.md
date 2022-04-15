# Fauna-Domain-Driven-IaC

This Action facilitates the use of [fauna-schema-migrate](https://github.com/fauna-labs/fauna-schema-migrate) in context of a domain based CI/CD workflow. Plus it supports applying a graphql schema to the database.

Manages your Fauna graphql schema, UDFs, indexes, roles, collections & access providers in GitHub and uploads it afterwards to Fauna.

## YAML Definition

Add the following snippet to the "steps" section of your `main.yml` file:

```yaml
steps:
  - name: Run Fauna Migration
    uses: Dechea/Fauna-Domain-Driven-IaC@v0.1.0
    with:
      GITHUB_PAT: '<string>'
      FAUNA_TOKEN: '<string>'
      DATABASE: '<string>'
      DOMAINS: '<string>' 
      FAUNA_DOMAIN: '<string>'
      # MUTATION_TEST: '<boolean>' # Optional
      # DEBUG: "<boolean>" # Optional
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| GITHUB_PAT (*)        | The key used to access your github repos. |
| FAUNA_TOKEN (*)       | The token used to access your Fauna database. |
| DATABASE (*)          | The target database where you want to apply the migration. |
| DOMAINS (*)           | Array with the repository names of the domains. <organization>/<repository>@<branch> |
| FAUNA_DOMAIN (*)      | The domain where your database are hosted e.g. db.fauna.com, db.eu.fauna.com etc.|
| MUTATION_TEST         | Runs mutations on top of your unit tests  (Only Jest supported ATM). See [Stryker-Mutator](https://stryker-mutator.io/) |
| DEBUG                 | Turn on extra debug information. Default: `false`. |

_(*) = required variable._

## Prerequisites

You will run all business logic in one databases, so that you have the full performance power of Fauna and every team has everytime a fully working database with all domains (Theoratically no need anymore for a staging environment). 
But we split the domains on the development side, so your teams can develop and ship features independently. Trying to get the best of both worlds.

### 1. Create in Fauna the domain relevant databases.

- One database for production
- One child database for staging (Optional)
- One child database for each domain e.g. Dev_User, Dev_Invoice

We have structured our databases in Fauna that way:

- <ProductName>
    - Production
    - Staging
    - Domains
        - USR_User
        - INV_Invoice

### 2. Create for every domain one repository in Bitbucket

Example:

- Repo 1: USR_User
- Repo 2: INV_Invoice

### 3. Follow the prefix naming pattern for all ressources

To achieve, that multiple teams can publish to one database, we have to follow a naming pattern to avoid merge conflicts because of duplicated collections, UDFs etc.
We're working with a unique prefix for every domain e.g. USR for User or INV for Invoice and so on.
This pattern needs to be applied as a prefix to your ressources and divided by a "_" from the rest of the name:

- Collections (e.g. "USR_Address" or "USR_SomethingElse")
- Indexes (e.g. "USR_GetAddressByUserId" or "USR_SomethingElse")
- Roles (e.g. "USR_GetAddressByUserId" or "USR_SomethingElse")
- UDFs (e.g. "USR_Administrator" or "USR_SomethingElse")
- Graphql schemas (e.g. "USR_Schema" or "USR_SomethingElse")
- Repository name (e.g. "USR_Schema" or "USR_SomethingElse") (Optional)
- Fauna domain databases (e.g. "USR_User" or "USR_SomethingElse") (Optional)

Good to know: If you follow these pattern, it's also relatively easy to have a code coverage report for every domain independently. You can do a code coverage inclusion in every repo for the files that are starting with the prefix of your own domain and then publish it e.g. to sonarcloud.

## Examples

### Deployment to Production database 
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-Domain-Driven-IaC@v0.1.0
        with:
          GITHUB_REPOSITORIES: 'Dechea/ORC_Schema@master,Dechea/USR_Schema@master,Dechea/CLS_Schema@master,Dechea/HES_Schema@master'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'Production'
          FAUNA_DOMAIN: ${{ secrets.FAUNA_URL }} # e.g. db.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_PRODUCTION }} # token for Production database
          MUTATION_TEST: 'true'
```
### Deployment to Domain Development database  
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-Domain-Driven-IaC@v0.1.0
        with:
          GITHUB_REPOSITORIES: 'Dechea/ORC_Schema@master,Dechea/USR_Schema@master,Dechea/CLS_Schema@master,Dechea/HES_Schema@master'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'USR_User'
          FAUNA_DOMAIN: ${{ secrets.FAUNA_URL }} # e.g. db.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_USR }} # token for USR_User database
          MUTATION_TEST: 'true'
```
  
## How it works
We have repositories created for every domain. Every repo has the structure defined by [fauna-schema-migrate](https://github.com/fauna-labs/fauna-schema-migrate). It includes collections, UDFs, Indexes, roles that are related to that domain. 
But we're using only one database. So one repo can't apply simply their infrastructure to the database. Instead we have to assemble it first with all other domain repos, run the tests and then apply it to the database. This is what this pipe does.
<br />
For that we using the data provided in the "DOMAINS" variable. We clone the repository branches based on the ENV, merge it, apply it to the given DATABASE and run all the tests.
<br /><br />
**How are we selecting the branches based on the ENV?**
This is different for every environment

- **Dev**: We pull from every repo the "Master" Branch except the repo that is currently running the pipe. From this repo we're using the branch that triggered the pipeline.
    - e.g. We push code into the Feature Branch "feature/Delete-User" of the repo "USR_Schema". The pipe will clone the feature branch of the repo "USR_Schema and from all other repos the "Master" Branch.
- **Staging**: We pull from every repo the "Staging" or "Release" Branch.
- **Prod**: We pull from every repo the "Master" Branch.

## Support
If you’d like help with this pipe, or you have an issue or feature request, let us know.
The pipe is maintained by ci-team@dechea.com.

If you’re reporting an issue, please include:

- the version of the action
- relevant logs and error messages
- steps to reproduce
