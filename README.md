# Fauna-IaC

This Action simplifies the use of [fauna-schema-migrate](https://github.com/fauna-labs/fauna-schema-migrate).
It can be used to deploy a mono repo to Fauna,
or it can be used to follow a Domain Driven approach with multiple repositories getting deployed to one database.

Manages 
- Graphql schema,
- UDFs, 
- Indexes, 
- Roles, 
- Collections 
- Access providers 
in GitHub and deploys it afterwards to Fauna.

## YAML Definition

Add the following snippet to the "steps" section of your `main.yml` file:

```yaml
steps:
  - name: Run Fauna Migration
    uses: Dechea/Fauna-IaC_Action@v1
    with:
      GITHUB_PAT: '<string>'
      FAUNA_TOKEN: '<string>'
      DATABASE: '<string>'
      DOMAINS: '<string>' 
      FAUNA_REGION: '<string>'
      # MUTATION_TEST: '<boolean>' # Optional
      # DEBUG: "<boolean>" # Optional
```
## Variables

| Variable           | Usage                                                                                                                   |
| ------------------ |-------------------------------------------------------------------------------------------------------------------------|
| GITHUB_PAT (*)     | The key used to access your github repos.                                                                               |
| FAUNA_TOKEN (*)    | The token used to access your Fauna database.                                                                           |
| DATABASE (*)       | The target database where you want to apply the migration.                                                              |
| DOMAINS (*)        | Array with the repository names of the domains. <organization>/<repository>@<branch>                                    |
| FAUNA_REGION       | The domain where your databases are hosted 'eu', 'us', 'classic', 'preview'                                                           |
| MUTATION_TEST      | Runs mutations on top of your unit tests  (Only Jest supported ATM). See [Stryker-Mutator](https://stryker-mutator.io/) |
| DEBUG              | Turn on extra debug information. Default: `false`.                                                                      |

_(*) = required variable._

## Prerequisites
  
Depending if you're following a Mono or Domain Driven repository approach, follow the corresponding prerequisite paths.
  
**Mono Repo:** 
One repo - one database (Traditional approach)
  
**Domain driven repositories:** 
You will run all business logic in one databases, so that you have the full performance power of Fauna and every team has everytime a fully working database with all domains (Theoratically no need anymore for a staging environment). But every team has an own repository with their own responsibility, so your teams can develop and ship features independently. Trying to get the best of both worlds - autonomy and performance.
  
### Mono Repository

#### 1. Follow the steps from [fauna-schema-migrate](https://github.com/fauna-labs/fauna-schema-migrate) 
#### 2. Create a PAT (Personal access token)
The PAT must have read & write access to the repositories. In the case of private repositories you'll want to create a machine user, add the machine user to the repositories that you want to checkout and then generate a token for the machine user.
  
### Domain Driven Repository  

#### 1. Create in Fauna the domain relevant databases.

- One database for production
- One child database for staging (Optional)
- One child database for each domain e.g. Dev_User, Dev_Invoice

We have structured our databases in Fauna that way:

<ul>
  <li>ProductName</li>
  <ul>
    <li>Production</li>
    <li>Staging</li>
    <li>Domains</li>
    <ul>
      <li>USR_User</li>
      <li>INV_Invoice</li>
    </ul> 
  </ul> 
</ul>  

#### 2. Create for every domain one repository in GitHub

Example:

- Repo 1: USR_User
- Repo 2: INV_Invoice

#### 3. Follow the prefix naming pattern for all ressources

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

Good to know: If you follow these pattern, it's also relatively easy to have a code coverage report for every domain independently. You can do a code coverage inclusion in every repo for the files that are starting with the prefix of your own domain and then publish it e.g. to Sonarcloud.
  
#### 4. Create a PAT (Personal access token)
The PAT must have read & write access to the repositories. In the case of private repositories you'll want to create a machine user, add the machine user to the repositories that you want to checkout and then generate a token for the machine user.

## Examples

### **Mono Repo:** Deployment to Production database 
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-IaC_Action@v1
        with:
          GITHUB_REPOSITORIES: 'Dechea/Fauna_Schema@main'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'Production'
          FAUNA_REGION: 'eu' # selects the EU URLs for fauna: db.eu.fauna.com, graphql.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_PRODUCTION }} # token for Production database
          MUTATION_TEST: 'true'
```
  
### **Domain Repos:** Deployment to Production database 
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-IaC_Action@v1
        with:
          GITHUB_REPOSITORIES: 'Dechea/ORC_Schema@main,Dechea/USR_Schema@main,Dechea/CLS_Schema@main,Dechea/HES_Schema@main'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'Production'
          FAUNA_REGION: 'eu' # selects the EU URLs for fauna: db.eu.fauna.com, graphql.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_PRODUCTION }} # token for Production database
          MUTATION_TEST: 'true'
```
### **Domain Repos:** Deployment to Domain Development database  
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-IaC_Action@v1
        with:
          GITHUB_REPOSITORIES: 'Dechea/HES_Schema@$GITHUB_REF_NAME,Dechea/ORC_Schema@main,Dechea/USR_Schema@main,Dechea/CLS_Schema@main'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'USR_User_Dev'
          FAUNA_REGION: 'eu' # selects the EU URLs for fauna: db.eu.fauna.com, graphql.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_USR }} # token for USR_User_Dev database
          MUTATION_TEST: 'true'
```
  
### Get coverage report 
```yaml  
name: Build and Deploy
on: [push]
jobs:
  build-and-deploy:
    concurrency: ci-${{ github.ref }} # Recommended if you intend to make multiple deployments in quick succession.
    runs-on: ubuntu-latest
    steps:
      - name: Run Fauna Migration
        uses: Dechea/Fauna-IaC_Action@v1
        with:
          GITHUB_REPOSITORIES: 'Dechea/HES_Schema@$GITHUB_REF_NAME,Dechea/ORC_Schema@main,Dechea/USR_Schema@main,Dechea/CLS_Schema@main'
          GITHUB_PAT: ${{ secrets.SCHEMA_PAT_GITHUB }}
          FAUNA_DATABASE: 'USR_User_Dev'
          FAUNA_REGION: 'eu' # selects the EU URLs for fauna: db.eu.fauna.com, graphql.eu.fauna.com
          FAUNA_SECRET: ${{ secrets.FAUNA_TOKEN_USR }} # token for USR_User_Dev database
          MUTATION_TEST: 'true'
  
      - uses: actions/download-artifact@v3
        name: Get coverage report artifact
        with:
          name: coverage-files
          path: coverage
```
  
## How it works
We have repositories created for every domain. Every repo has the structure defined by [fauna-schema-migrate](https://github.com/fauna-labs/fauna-schema-migrate). It includes collections, UDFs, Indexes, roles that are related to that domain. 
But we're using only one database. So one repo can't apply simply their infrastructure to the database. Instead we have to assemble it first with all other domain repos, run the tests and then apply it to the database. This is what this Action does.
<br />
For that we using the data provided in the "GITHUB_REPOSITORIES" variable. We clone the repositories, merge it, apply it to the given FAUNA_DATABASE and run all the tests.
<br /><br />

## TBD  

- Bring support for multiple test runners (Jest, AVA, Mocha etc.)
- Automatically code coverage upload to Sonarcloud, codecov etc.
- Run test in parallel
- Apply migration to multiple databases at once  
  
## Q&A

### 1. What happens if one domain introduce a breaking change?
Currently the whole Action would fail, because we run all tests from all Domains. Only if all tests passing, the changes will be applied to production.
  
## Support
If you’d like help with this pipe, or you have an issue or feature request, let us know.
Pull requests are welcome!
  
If you’re reporting an issue, please include:

- the version of the action
- relevant logs and error messages
- steps to reproduce
