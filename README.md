# Hiera vault backend

## Description

This module provides a Hiera 5 backend for looking up secret data stored in Hashicorp Vault.

## Setup
### Hiera Configuration

Each `vault_lookup_key` level will return at most one secret data item. Multiple
paths may be added to `secret_base` to be searched in order. The first match
will be returned

```yaml
---
version: 5
hierarchy:
  - name: "Vault secrets (common)"
    lookup_key: vault_lookup_key
    options:
      secret_base: "/secret/puppet"  # Vault lookup path 
      default_key: value                     
      vault_token: <token_for_puppet_use>
      vault_addr: https://vault.local:8200
      vault_key_file: /path/to/file.key
      ssl_verify: false  # defaults to true   
      ssl_ciphers: "TLSv1:!aNULL:!eNULL"
      ssl_ca_cert: /etc/pki/.../localhost.crt # applicable when ssl_verify is set to true      

```

### Beginning with vault_integration

The `vault` RubyGem must be present for the Hiera backend to work. The gem can
be installed manually, i.e. `/opt/puppetlabs/puppet/bin/gem install vault` for
use with the client `puppet` agent CLI or via Puppet:

```puppet
package { 'vault':
  ensure   => ['0.10.1'],
  provider => puppet_gem,
}
```

[puppetlabs-puppetserver_gem](https://github.com/puppetlabs/puppetlabs-puppetserver_gem) can be used to install the `vault` gem on Puppet servers.

## Usage

