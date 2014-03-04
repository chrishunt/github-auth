# Changelog

##v3.1.0
*2014-03-04*

- [Use Faraday instead of HTTParty](https://github.com/chrishunt/github-auth/pull/31)
- [Update gems](https://github.com/chrishunt/github-auth/pull/32)

##v3.0.2
*2014-01-19*

[\[22 commits\]](https://github.com/chrishunt/github-auth/compare/v3.0.1...v3.0.2)

- [Remove Gemfile.lock from repo, update all gems](https://github.com/chrishunt/github-auth/pull/27)
- [Mute specs](https://github.com/chrishunt/github-auth/pull/28)

##v3.0.1
*2013-10-25*

[\[8 commits\]](https://github.com/chrishunt/github-auth/compare/v3.0.0...v3.0.1)

- [URL escape GitHub usernames](https://github.com/chrishunt/github-auth/pull/20)
- [Show pretty file permission errors for `list` command](https://github.com/chrishunt/github-auth/pull/21)

##v3.0.0
*2013-10-24*

[\[19 commits\]](https://github.com/chrishunt/github-auth/compare/v2.0.0...v3.0.0)

*note:* CLI syntax has changed in this release as a result of switching to
[`Thor`](https://github.com/erikhuda/thor). See the
[`README`](https://github.com/chrishunt/github-auth/blob/master/README.md) for
usage instructions.

- [Use `Thor` for parsing CLI options](https://github.com/chrishunt/github-auth/pull/18)
- [Add `--command` option for custom ssh commands](https://github.com/chrishunt/github-auth/pull/18)
- [Add `--host` option for specifying GitHub host](https://github.com/chrishunt/github-auth/pull/18)
- [Add `--path` option for specifying keys file path](https://github.com/chrishunt/github-auth/pull/18)

##v2.0.0
*2013-10-22*

[\[22 commits\]](https://github.com/chrishunt/github-auth/compare/v1.2.0...v2.0.0)

*note:* Option syntax has changed in this release as a result of switching to
`OptionParser`. See the [`README`](https://github.com/chrishunt/github-auth/blob/master/README.md)
for usage instructions.

- [Add `--list` command](https://github.com/chrishunt/github-auth/pull/14)
- [Use `OptionParser` for parsing CLI options](https://github.com/chrishunt/github-auth/pull/16)

##v1.2.0
*2013-08-20*

[\[18 commits\]](https://github.com/chrishunt/github-auth/compare/v1.1.0...v1.2.0)

- [Add a newline at the very end of the keys file](https://github.com/chrishunt/github-auth/pull/9)
- [Fix RSpec deprecation warnings](https://github.com/chrishunt/github-auth/pull/11)
- [Add gem versions to gemspec](https://github.com/chrishunt/github-auth/commit/1296e2ebd4e4e13d80775c81ec8ca2ac3710d20c)

##v1.1.0
*2013-05-29*

[\[13 commits\]](https://github.com/chrishunt/github-auth/compare/v1.0.0...v1.1.0)

- Add link to user's GitHub profile as comment on SSH keys
- Add VPN/tunneling solutions to README
- Add CHANGELOG

##v1.0.0
*2013-05-18*

[\[2 commits\]](https://github.com/chrishunt/github-auth/compare/v0.6.1...v1.0.0)

Nobody is complaining about bugs, so we're ready to call it **v1.0.0**

##v0.6.1
*2013-05-10*

[\[7 commits\]](https://github.com/chrishunt/github-auth/compare/v0.6.0...v0.6.1)

- Add License information to README

##v0.6.0
*2013-05-09*

[\[6 commits\]](https://github.com/chrishunt/github-auth/compare/v0.5.0...v0.6.0)

- Only insert blank line if inserting a key
- Don't leave blank lines when writing keys

##v0.5.0
*2013-05-08*

[\[13 commits\]](https://github.com/chrishunt/github-auth/compare/v0.4.1...v0.5.0)

- Remove line break as well when deleting keys
- Enforce Ruby 1.9 hash syntax with Cane
- Move contributing instructions to separate doc

##v0.4.1
*2013-04-28*

[\[15 commits\]](https://github.com/chrishunt/github-auth/compare/v0.4.0...v0.4.1)

- Check code quality by default when running specs
- Add cane as development dependency

##v0.4.0
*2013-04-25*

[\[3 commits\]](https://github.com/chrishunt/github-auth/compare/v0.3.0...v0.4.0)

- Add `--version` option to command line client

##v0.3.0
*2013-04-25*

[\[5 commits\]](https://github.com/chrishunt/github-auth/compare/v0.2.0...v0.3.0)

- Send github-auth user agent to GitHub when making requests

##v0.2.0
*2013-04-22*

[\[8 commits\]](https://github.com/chrishunt/github-auth/compare/v0.1.1...v0.2.0)

- Correctly remove keys with comments in keys file

##v0.1.1
*2013-04-15*

[\[6 commits\]](https://github.com/chrishunt/github-auth/compare/v0.1.0...v0.1.1)

- Adjustments to README

##v0.1.0
*2013-04-15*

Initial release
