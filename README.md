# github-auth

[![](http://img.shields.io/travis/chrishunt/github-auth.svg?style=flat)](https://travis-ci.org/chrishunt/github-auth)
[![](http://img.shields.io/codeclimate/github/chrishunt/github-auth.svg?style=flat)](https://codeclimate.com/github/chrishunt/github-auth)
[![](http://img.shields.io/gem/v/github-auth.svg?style=flat)](http://rubygems.org/gems/github-auth)

### Pairing with strangers has never been so good.

**github-auth** allows you to quickly pair with anyone who has a GitHub account
by adding and removing their public ssh keys from your
[`authorized_keys`](http://en.wikipedia.org/wiki/Ssh-agent) file.

## Description

If you agree to [\#pairwithme](https://twitter.com/search?q=pairwithme), we'll
probably be SSHing into my laptop, your laptop, or some laptop in the sky.
Sharing passwords over email is no fun, so we'll use public key authentication
to keep things fun, fast, and secure.

Let's see how this works.

After you've [installed](#installation) `gh-auth`, you can give me ssh access
with:

```bash
$ gh-auth add --users=chrishunt
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

If you'd like me to automatically connect to your existing tmux session, you
can do that with a custom ssh command:

```bash
$ gh-auth add --users=chrishunt --command="tmux attach"
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

Allowing someone to SSH to your machine can be a scary thing. Restricting them
to a single command goes a little way to help secure things. If you want to
keep them from forwarding ports, you can use the `--ssh-options` option to
add that to their key entry.

```bash
$ gh-auth add --users=chrishunt --ssh-options=no-port-forwarding
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

As a convenience, you may also use the `--no-forwarding` option to prevent all
forwarding (i.e. `no-port-forwarding,no-X11-forwarding,no-agent-forwarding`).

```bash
$ gh-auth add --users=chrishunt --no-forwarding
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

That was easy! When we're done working, you can revoke my access with:

```bash
$ gh-auth remove --users=chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'
```

You can add and remove any number of users at the same time.

```bash
$ gh-auth add --users=chrishunt zachmargolis
Adding 4 key(s) to '/Users/chris/.ssh/authorized_keys'

$ gh-auth list
chrishunt zachmargolis

$ gh-auth remove --users=chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'

$ gh-auth list
zachmargolis

$ gh-auth remove --users=zachmargolis
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'

$ gh-auth list

```

If you'd like to remove all GitHub users in one fatal swoop, you can do that
too.

```bash
$ gh-auth remove --users=`gh-auth list`
```

## Sections

  1. [Usage](#usage)
     - [Command Line](#command-line)
     - [In Your Project](#in-your-project)
  1. [Installation](#installation)
     - [SSH Public Key Authentication](#ssh-public-key-authentication-mac-os-x)
     - [Verification](#verification)
  1. [Troubleshooting](#troubleshooting)
     - [How do people actually connect to my machine?](#how-do-people-actually-connect-to-my-machine)
     - [What username do I use?](#what-username-do-i-use)
     - [How do I get my external IP?](#how-do-i-get-my-external-ip)
     - [It's still not working!](#its-still-not-working-)
     - [I can't enable port forwarding](#i-cant-enable-port-forwarding-my-boss-wont-let-me-can-i-still-pair)
  1. [Contributing](#contributing)
  1. [Changelog](#changelog)
  1. [License](#license)

## Usage

### Command Line

`gh-auth` can be used from the command line after the gem has been installed.

```
$ gh-auth
Commands:
  gh-auth add --users=one two three     # Add GitHub users to authorized keys
  gh-auth help [COMMAND]                # Describe available commands or one specific command
  gh-auth list                          # List all GitHub users already added to authorized keys
  gh-auth remove --users=one two three  # Remove GitHub users from authorized keys
  gh-auth version                       # Show gh-auth version

Options:
  [--host=HOST]
  [--path=PATH]
```

Use the `help` command for help on a specific command.

```
$ gh-auth help add
Usage:
  gh-auth add --users=one two three

Options:
  --users=one two three
  [--command=COMMAND]
  [--host=HOST]
  [--path=PATH]

Description:
  `gh-auth add` is used to add one or more GitHub user's public SSH keys to ~/.ssh/authorized_keys. All keys stored on github.com for that user will be added.

  > $ gh-auth add --users=chrishunt zachmargolis
  > Adding 6 key(s) to '/Users/chris/.ssh/authorized_keys'

  By default, users will be granted normal shell access. If you'd like to specify an ssh command that should execute when the user connects, use the `--command` option.

  > $ gh-auth add --users=chrishunt --command="tmux attach"
```

### In Your Project

Want to add/remove keys in your project, but not on the command line? That's ok
too.

```ruby
require 'github/auth'

# Add keys for GitHub user 'chrishunt'
GitHub::Auth::CLI.start %w(add --users=chrishunt)

# Remove keys for GitHub user 'chrishunt'
GitHub::Auth::CLI.start %w(remove --users=chrishunt)
```

## Installation

Install the `github-auth` gem:

```bash
$ gem install github-auth
```

### SSH Public Key Authentication (Mac OS X)

Public key authentication works with Mac OS by default, but you'll need to get
your ssh server running. This is done by ticking 'Remote Login' in the
'Sharing' panel of System Preferences.

![](https://raw.github.com/chrishunt/github-auth/master/img/mac-os-ssh-sharing.jpg)

Now that SSH is running, make sure you have the correct permissions set for
your authorized keys.

```bash
$ chmod 700 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```

### Verification

If you'd like to verify that everything is working as expected, you can test
locally on your own machine.

First, authorize yourself for ssh. (Make sure to replace 'chrishunt' with
*your* GitHub username)

```bash
$ gh-auth add --users=chrishunt
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

Now that your keys are added, verify that you can open an SSH session to your
machine with public key authentication:

```bash
$ ssh -o PreferredAuthentications=publickey localhost

(localhost)$
```

Next, remove your public keys from the keys file:

```bash
$ gh-auth remove --users=chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'
```

Now that you've removed your keys, verify that you can no longer log in to your
machine with public key authentication:

```bash
$ ssh -o PreferredAuthentications=publickey localhost

> Permission denied (publickey,keyboard-interactive)
```

## Troubleshooting

### How do people actually connect to my machine?

Good question! Others will connect to your machine using ssh:

```bash
$ ssh username@external-ip-address
```

### What username do I use?

The `username` is going to be the same username that you used to add the keys.
In most cases, it's a good idea to create a new `pair` account and use that
account for all pairings. You don't want strangers reading your email!

Once you've created the pair account, you can switch to it yourself in a
terminal with:

```bash
$ su - pair
```

### How do I get my external IP?

You can get your external IP address with:

```bash
$ curl http://checkip.amazonaws.com/
```

### It's still not working! :(

In almost all cases, your laptop is not directly plugged into your modem.
You're on a wireless network or plugged directly into a router or switch. This
means the external IP address that your pair is connecting to is not your
machine, it's actually your router.

You can tell your router to forward ssh connections to your machine by enabling
[port forwarding](http://en.wikipedia.org/wiki/Port_forwarding). You will want
to forward port `22` (ssh) to the local IP address of your machine.

If port `22` is already forwarded to another machine or you want to change
things up, you can have ssh listen on another port and have your pair connect
with:

```bash
ssh -p <port> username@external-ip-address
```

### I can't enable port forwarding, my boss won't let me. Can I still pair?

Yes! A nice solution to this is to have a machine **somewhere else** that both
of you can ssh into. Place this machine on a network that you *do* have the
ability to forward ports. Maybe this machine is at home, a friend's house, or
at a company you worked for in the past that forgot to turn it off.

If this isn't possible, then you can use a VPS provider like
[Linode](http://www.linode.com) to setup a pairing machine in the cloud or a
tunneling solution like [PageKite](https://pagekite.net) or
[Hamachi](https://secure.logmein.com/products/hamachi) to make your machine
accessible without forwarding ports.

## Contributing
Please see the [Contributing
Document](https://github.com/chrishunt/github-auth/blob/master/CONTRIBUTING.md)

## Changelog
Please see the [Changelog
Document](https://github.com/chrishunt/github-auth/blob/master/CHANGELOG.md)

## License
Copyright (C) 2013 Chris Hunt, [MIT
License](https://github.com/chrishunt/github-auth/blob/master/LICENSE.txt)
