# puppet-module-zabbix_extras

[![Build Status](https://travis-ci.org/treydock/puppet-module-zabbix_extras.png)](https://travis-ci.org/treydock/puppet-module-zabbix_extras)

####Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [TODO](#todo)
7. [Additional Information](#additional-information)

## Overview

This module manages Zabbix agent extras such as custom scripts for custom Zabbix checks.

## Usage

TODO

## Reference

### Classes

#### Public classes

* `zabbix::agent::fhgfs`: Custom checks for FhGFS
* `zabbix::agent::filesystem`: Custom checks for filesystems

#### Private classes

* `zabbix::params`: Sets parameter defaults based on fact values.

### Parameters

TODO

## Limitations

This module has been tested on:

* CentOS 6.5 x86_64
* CentOS 7.0 x86_64

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake beaker

## TODO

## Further Information

