# Changelog

## v2.3.2 (Aug 31, 2021)

* [CHANGE] Update usage to support WHMCS 8.2.

## v2.2.1 (Mar 1, 2021)

* [FIX] Link legacy whmcs users.

***

## v2.2.0 (Dec 9, 2020)

* [CHANGE] Bump ActiveSupport to v6.1.

***

## v2.1.0 (July 18, 2020)

* [FEATURE] You may now specify what day of the month the invoice will be due, and when to generate the invoice. Billable items are created on the last day of the month, so you may now choose to have the invoice generated on the due date (default), or immediately on the next cron run. By choosing next cron run, you may set the due date later in the month to allow your customers a certain number of days before the invoice is due.

***

## v2.0.0 (June 8, 2020)

**NOTE: Major breaking changes in v2! You must be using ComputeStacks v6+ or greater to make use of these changes.**

This release includes a brand new plugin architecture for ComputeStacks that exposes webhooks to our plugins.

* [FEATURE] Support for our new WHMCS plugin that allows for creating multiple CS accounts per WHMCS user

***

## v1.1.0 (Jan 15, 2020)

* [FEATURE] Lookup a clientid by their product username
* [FEATURE] List available payment methods for a user
