# WHMCS Billing Plugin for ComputeStacks

## Overview

* `User.external_id` = `serviceid` in WHMCS
* Uses the following labels:
    * `{ 'whmcs' => { 'client_id' => '', 'service_id' => '' } }`
* 1 account in CS = 1 account in WHMCS
* When enabling, it will automatically disable user registration. However, you can manually re-enable that.

## WHMCS API Credentials

When generating API Credentials, here are a list of all the required actions:

* `Billing -> AddBillableItem`
* `Client -> GetClients`
* `Client -> GetClientsDetails`
* `Client -> GetClientsProducts`
* `Products -> GetProducts`
* `Products -> UpdateClientProduct`
* `Servers -> GetHealthStatus`
* `Servers -> WhmcsDetails`

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Environmental Variables

We use [direnv](https://direnv.net/) to manage our env file, alternatively you can manually export the variables. See `envrc.sample` for details.

Using _direnv_, you can:

* `mv envrc.sample .envrc` and adjust accordingly
* run `direnv allow .`

### Running Tests

`bundle exec rake test`

#### WHMCS Test Setup

1. Create cpanel server with hostname: `mycpanelserver.net` -- doesn't have to actually exist.

2. Create server group and assign server

3. Create product assigned to previously created server group (under modules)

4. Create user with email jane.doe@example.com. Record `userid` as `WHMCS_TEST_USER_ID`.

5. Add new order for user (skip invoice, emails, etc) and accept order. Set username to `jane.doe3-10@demo.computestacks.net`.

6. Record `serviceid` in your `.env` file for `WHMCS_TEST_SERVICE_ID`.

_Be sure to delete the billable items after you run the tests. There is no WHMCS api to do that automatically._

