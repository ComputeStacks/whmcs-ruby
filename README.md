# WHMCS for ComputeStacks


## Basic Setup
```ruby
Whmcs.configure(endpoint: '', api_key: '', api_secret: '')
```


## List all users with a given product username

This is useful if you have a cpanel username but not the account in whmcs.

```ruby
response = Whmcs::User.list_by_product_user('')
```
