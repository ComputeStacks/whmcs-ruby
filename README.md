# WHMCS Billing Plugin for ComputeStacks

## WHMCS API Credentials

When generating API Credentials, here are a list of all the required actions:

* `Billing -> AddBillableItem`
* `Client -> GetClients`
* `Client -> GetClientsDetails`
* `Client -> GetClientsProducts`
* `Products -> GetProducts`
* `Servers -> GetHealthStatus`

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Environmental Variables

We use [direnv](https://direnv.net/) to manage our env file, alternatively you can manually export the variables. See `envrc.sample` for details.

Using _direnv_, you can:

* `mv envrc.sample .envrc` and adjust accordingly
* run `direnv allow .`

### Sensitive Data

Before commiting new `vcr` fixtures, please scrub any personal information from them.
