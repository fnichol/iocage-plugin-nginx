# iocage-plugin-nginx

An [iocage][] plugin for [nginx][], a Robust and small WWW server.

[iocage]: https://github.com/iocage/iocage
[nginx]: https://www.nginx.com/

|         |                                      |
| ------: | ------------------------------------ |
|      CI | [![CI Status][badge-ci-overall]][ci] |
| License | [![License][badge-license]][license] |

**Table of Contents**

<!-- toc -->

- [Installation](#installation)
- [Usage](#usage)
  - [Enabling TLS Mode with an SSL Certificate](#enabling-tls-mode-with-an-ssl-certificate)
  - [Persisting Data](#persisting-data)
- [Configuration](#configuration)
  - [User Serviceable Configuration](#user-serviceable-configuration)
  - [`nginx_mode`](#nginx_mode)
  - [System Configuration](#system-configuration)
  - [`nginx_listen_addr`](#nginx_listen_addr)
- [Code of Conduct](#code-of-conduct)
- [Issues](#issues)
- [Contributing](#contributing)
- [Release History](#release-history)
- [Authors](#authors)
- [License](#license)

<!-- tocstop -->

## Installation

This plugin can be installed via the [fnichol/iocage-plugin-index][index] plugin
collection which is not installed on FreeNAS or TrueOS by default. For example,
to install the plugin with a name of `nginx` and a dedicated IP address:

```console
$ jail=www
$ ip_addr=10.200.0.110

$ sudo iocage fetch \
  -g https://github.com/fnichol/iocage-plugin-index \
  -P nginx \
  --name $jail \
  ip4_addr="vnet0|$ip_addr"
```

[index]: https://github.com/fnichol/iocage-plugin-index

## Usage

### Enabling TLS Mode with an SSL Certificate

To enable TLS you will need a public SSL certificate (i.e. a `cert.pem` file)
and the private server key (i.e. a `key.pem` file) installed into the nginx
configuration directory of the plugin's jail. Assuming a running installed
plugin called `www` with a jail mount point of `/mnt/tank/iocage/jails/www` in
the host system, the following will setup nginx to run under HTTPS:

```console
$ jail=www
$ jail_mnt=/mnt/tank/iocage/jails/$jail

$ sudo cp cert.pem key.pem $jail_mnt/root/usr/local/etc/nginx/
$ sudo chown 0644 $jail_mnt/root/usr/local/etc/nginx/cert.pem
$ sudo chown 0600 $jail_mnt/root/usr/local/etc/nginx/key.pem
$ sudo iocage exec $jail plugin config set nginx_mode https
$ sudo iocage exec $jail plugin services restart
```

### Persisting Data

There is 1 primary directory that may contain data in an nginx jail:

- `/usr/local/www/nginx` The web site content served up by nginx

A good strategy is to create a ZFS dataset for this directory or use an existing
dataset and mount it into the jail. This way, the jail can be destroyed and
later re-created without losing the served up web content.

```console
$ jail=www
$ dataset=tank/website
$ mnt=/mnt/$dataset

# Attach an existing ZFS dataset to be served
$ sudo iocage exec $jail rm -rf /usr/local/www/nginx
$ sudo iocage exec $jail mkdir /usr/local/www/nginx
$ sudo iocage fstab -a $jail "$mnt /usr/local/www/nginx nullfs ro 0 0"

# Restart the nginx service
$ sudo iocage exec $jail plugin services restart
```

## Configuration

### User Serviceable Configuration

The following configuration is intended to be modified by a plugin user.

### `nginx_mode`

Whether or not TLS is being used for the service. See the TLS section for more
information regarding how to install an SSL certificate.

- default: `"http"`
- valid values: `"http"`|`"https"`|`"https-only"`

Note that `"https-"` mode runs the service on `HTTP` and `HTTPS` whereas
`"https-only"` mode only runs on `HTTPS`.

To change this value, use the installed `plugin` program and restart the
services to apply the updated configuration:

```console
$ plugin config set nginx_mode http
$ plugin services restart
```

### System Configuration

The following configuration is used to configure and setup the services during
post installation and is therefore not intended to be changed or modified by a
plugin user.

### `nginx_listen_addr`

Listen address for the service.
([nginx reference](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen))

- default: `"0.0.0.0"`

## Code of Conduct

This project adheres to the Contributor Covenant [code of
conduct][code-of-conduct]. By participating, you are expected to uphold this
code. Please report unacceptable behavior to fnichol@nichol.ca.

## Issues

If you have any problems with or questions about this project, please contact us
through a [GitHub issue][issues].

## Contributing

You are invited to contribute to new features, fixes, or updates, large or
small; we are always thrilled to receive pull requests, and do our best to
process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub
issue][issues], especially for more ambitious contributions. This gives other
contributors a chance to point you in the right direction, give you feedback on
your design, and help you find out if someone else is working on the same thing.

## Release History

This project uses a "deployable master" strategy, meaning that the `master`
branch is assumed to be working and production ready. As such there is no formal
versioning process and therefore also no formal changelog documentation.

## Authors

Created and maintained by [Fletcher Nichol][fnichol] (<fnichol@nichol.ca>).

## License

Licensed under the Mozilla Public License Version 2.0 ([LICENSE.txt][license]).

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the MPL-2.0 license, shall be
licensed as above, without any additional terms or conditions.

[badge-license]: https://img.shields.io/badge/License-MPL%202.0%20-blue.svg
[badge-ci-overall]:
  https://api.cirrus-ci.com/github/fnichol/iocage-plugin-nginx.svg
[ci]: https://cirrus-ci.com/github/fnichol/iocage-plugin-nginx
[code-of-conduct]:
  https://github.com/fnichol/iocage-plugin-nginx/blob/master/CODE_OF_CONDUCT.md
[fnichol]: https://github.com/fnichol
[issues]: https://github.com/fnichol/iocage-plugin-nginx/issues
[license]:
  https://github.com/fnichol/iocage-plugin-nginx/blob/master/LICENSE.txt
