# github-auth `gh-auth`
[![Travis CI](https://travis-ci.org/chrishunt/github-auth.png)](https://travis-ci.org/chrishunt/github-auth)
[![Coverage Status](https://coveralls.io/repos/chrishunt/github-auth/badge.png?branch=master)](https://coveralls.io/r/chrishunt/github-auth)
[![Code Climate](https://codeclimate.com/github/chrishunt/github-auth.png)](https://codeclimate.com/github/chrishunt/github-auth)

## Description

If you agree to [\#pairwithme](https://twitter.com/search?q=pairwithme), we'll
probably be SSHing into my laptop, your laptop, or some laptop in the sky.
Sharing passwords over email is no fun, so we'll use public key authentication
to keep things fun, fast, and **secure**

`gh-auth` allows you to quickly add and remove any Github user's public ssh
keys from your [`authorized_keys`](http://en.wikipedia.org/wiki/Ssh-agent)
file.

Let's see how this works.

After you've [installed](#installation) `gh-auth`, you can give me ssh access
with:

```bash
$ gh-auth add chrishunt
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

That was easy! When we're done working, you can revoke my access with:

```bash
$ gh-auth remove chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'
```

You can add and remove any number of users at the same time.

```bash
$ gh-auth add chrishunt zachmargolis
Adding 4 key(s) to '/Users/chris/.ssh/authorized_keys'

$ gh-auth remove chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'

$ gh-auth remove zachmargolis
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'
```

## Usage

```bash
usage: gh-auth [--version] [add|remove] <username>
```

## Installation

Install the `github-auth` gem:

```bash
$ gem install github-auth

$ gh-auth
usage: gh-auth [--version] [add|remove] <username>
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
right from your machine.

First, authorized yourself for ssh. (Make sure to replace 'chrishunt' with
*your* Github username)

```bash
$ gh-auth add chrishunt
Adding 2 key(s) to '/Users/chris/.ssh/authorized_keys'
```

Next, open an SSH session to your machine with public key authentication. It
should work just fine.

```bash
$ ssh -o PreferredAuthentications=publickey localhost

(localhost)$
```

Now remove your public keys from the keys file:

```bash
$ gh-auth remove chrishunt
Removing 2 key(s) from '/Users/chris/.ssh/authorized_keys'
```

You should no longer be able to login to the machine since the keys have been
removed.

```bash
$ ssh -o PreferredAuthentications=publickey localhost

> Permission denied (publickey,keyboard-interactive)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run the tests (`bundle exec rake spec`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
