# Change Log

## [Unreleased](https://github.com/lanej/cistern/tree/HEAD)

[Full Changelog](https://github.com/lanej/cistern/compare/v2.7.0...HEAD)

**Implemented enhancements:**

- custom wait for lambdas [\#21](https://github.com/lanej/cistern/issues/21)
- accept alias as a attribute parameter [\#20](https://github.com/lanej/cistern/issues/20)
- Offer mock data adapters [\#19](https://github.com/lanej/cistern/issues/19)
- request method model [\#4](https://github.com/lanej/cistern/issues/4)
- Service\#requires\_one [\#3](https://github.com/lanej/cistern/issues/3)

**Merged pull requests:**

- feature: allow using `super` to override association methods [\#73](https://github.com/lanej/cistern/pull/73) ([lanej](https://github.com/lanej))
- fix\(associations\): enable attribute options and method scope blocks [\#72](https://github.com/lanej/cistern/pull/72) ([lanej](https://github.com/lanej))

## [v2.7.0](https://github.com/lanej/cistern/tree/v2.7.0) (2016-08-10)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.6.0...v2.7.0)

**Merged pull requests:**

- fix\(singular\): add associations support [\#70](https://github.com/lanej/cistern/pull/70) ([lanej](https://github.com/lanej))
- refactor\(request\): cleanup and document interface [\#69](https://github.com/lanej/cistern/pull/69) ([lanej](https://github.com/lanej))
- Add a Gitter chat badge to README.md [\#68](https://github.com/lanej/cistern/pull/68) ([gitter-badger](https://github.com/gitter-badger))

## [v2.6.0](https://github.com/lanej/cistern/tree/v2.6.0) (2016-07-26)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.5.0...v2.6.0)

**Implemented enhancements:**

- Associations [\#66](https://github.com/lanej/cistern/pull/66) ([lanej](https://github.com/lanej))

**Fixed bugs:**

- fix\(model\): \#has\_many is not loaded without records present [\#67](https://github.com/lanej/cistern/pull/67) ([lanej](https://github.com/lanej))

## [v2.5.0](https://github.com/lanej/cistern/tree/v2.5.0) (2016-07-19)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.4.1...v2.5.0)

**Implemented enhancements:**

- add request\_attributes, dirty\_request\_attributes helpers [\#65](https://github.com/lanej/cistern/pull/65) ([lanej](https://github.com/lanej))

## [v2.4.1](https://github.com/lanej/cistern/tree/v2.4.1) (2016-07-16)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.4.0...v2.4.1)

**Merged pull requests:**

- fix\(attributes\): child classes inherit parent identity [\#64](https://github.com/lanej/cistern/pull/64) ([lanej](https://github.com/lanej))

## [v2.4.0](https://github.com/lanej/cistern/tree/v2.4.0) (2016-07-11)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.3.0...v2.4.0)

**Implemented enhancements:**

- refactor\(singular\): a collection-less model [\#61](https://github.com/lanej/cistern/pull/61) ([lanej](https://github.com/lanej))

**Merged pull requests:**

- test\(ci\): use `appraisal` for gemfile splitting [\#63](https://github.com/lanej/cistern/pull/63) ([lanej](https://github.com/lanej))
- modernize README [\#62](https://github.com/lanej/cistern/pull/62) ([lanej](https://github.com/lanej))
- feature\(hash\): refactor implementation, mixin helpers [\#60](https://github.com/lanej/cistern/pull/60) ([lanej](https://github.com/lanej))
- refactor\(attributes\): overhaul internals [\#59](https://github.com/lanej/cistern/pull/59) ([lanej](https://github.com/lanej))
- fix\(attributes\): allow string types to be nil [\#58](https://github.com/lanej/cistern/pull/58) ([lanej](https://github.com/lanej))
- Tweaks for Readme [\#56](https://github.com/lanej/cistern/pull/56) ([jaw6](https://github.com/jaw6))

## [v2.3.0](https://github.com/lanej/cistern/tree/v2.3.0) (2016-05-17)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.7...v2.3.0)

**Implemented enhancements:**

- 'requires' function should return a hash of matching requirements [\#45](https://github.com/lanej/cistern/issues/45)

**Closed issues:**

- rename `service` to `cistern` [\#50](https://github.com/lanej/cistern/issues/50)

**Merged pull requests:**

- add return values for \#requires and \#requires\_one [\#55](https://github.com/lanej/cistern/pull/55) ([lanej](https://github.com/lanej))
- officially deprecate class interface [\#54](https://github.com/lanej/cistern/pull/54) ([lanej](https://github.com/lanej))
- use \#stage\_attributes to make \#dirty\_attributes available on \#update [\#53](https://github.com/lanej/cistern/pull/53) ([lanej](https://github.com/lanej))
- deprecate \#service, use \#cistern [\#52](https://github.com/lanej/cistern/pull/52) ([lanej](https://github.com/lanej))

## [v2.2.7](https://github.com/lanej/cistern/tree/v2.2.7) (2016-05-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.6...v2.2.7)

**Merged pull requests:**

- service is not required to determine \#missing\_attributes [\#51](https://github.com/lanej/cistern/pull/51) ([lanej](https://github.com/lanej))

## [v2.2.6](https://github.com/lanej/cistern/tree/v2.2.6) (2016-02-28)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.5...v2.2.6)

## [v2.2.5](https://github.com/lanej/cistern/tree/v2.2.5) (2016-01-14)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.4...v2.2.5)

## [v2.2.4](https://github.com/lanej/cistern/tree/v2.2.4) (2015-11-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.3...v2.2.4)

**Closed issues:**

- Optional coverage feature creates too many NoMethodErrors [\#49](https://github.com/lanej/cistern/issues/49)

## [v2.2.3](https://github.com/lanej/cistern/tree/v2.2.3) (2015-10-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.2...v2.2.3)

## [v2.2.2](https://github.com/lanej/cistern/tree/v2.2.2) (2015-10-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.1...v2.2.2)

## [v2.2.1](https://github.com/lanej/cistern/tree/v2.2.1) (2015-10-02)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.2.0...v2.2.1)

## [v2.2.0](https://github.com/lanej/cistern/tree/v2.2.0) (2015-10-02)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.1.0...v2.2.0)

## [v2.1.0](https://github.com/lanej/cistern/tree/v2.1.0) (2015-09-29)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.5...v2.1.0)

## [v2.0.5](https://github.com/lanej/cistern/tree/v2.0.5) (2015-09-21)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.4...v2.0.5)

## [v2.0.4](https://github.com/lanej/cistern/tree/v2.0.4) (2015-09-10)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.12.2...v2.0.4)

**Closed issues:**

- Cistern::Model\#new\_record? raises TypeError when @identity is not set with 2.0.3 [\#48](https://github.com/lanej/cistern/issues/48)

## [v0.12.2](https://github.com/lanej/cistern/tree/v0.12.2) (2015-09-01)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.12.1...v0.12.2)

## [v0.12.1](https://github.com/lanej/cistern/tree/v0.12.1) (2015-09-01)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.12.0...v0.12.1)

## [v0.12.0](https://github.com/lanej/cistern/tree/v0.12.0) (2015-09-01)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.3...v0.12.0)

**Closed issues:**

- Cistern::Model\#inspect raises TypeError when @identity is not defined [\#47](https://github.com/lanej/cistern/issues/47)

## [v2.0.3](https://github.com/lanej/cistern/tree/v2.0.3) (2015-08-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.2...v2.0.3)

**Merged pull requests:**

- minor docs cleanup [\#46](https://github.com/lanej/cistern/pull/46) ([thommahoney](https://github.com/thommahoney))

## [v2.0.2](https://github.com/lanej/cistern/tree/v2.0.2) (2015-03-31)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.11.3...v2.0.2)

## [v0.11.3](https://github.com/lanej/cistern/tree/v0.11.3) (2015-03-31)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.1...v0.11.3)

## [v2.0.1](https://github.com/lanej/cistern/tree/v2.0.1) (2015-03-05)
[Full Changelog](https://github.com/lanej/cistern/compare/v2.0.0...v2.0.1)

## [v2.0.0](https://github.com/lanej/cistern/tree/v2.0.0) (2015-03-05)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.0...v2.0.0)

## [v1.0.0](https://github.com/lanej/cistern/tree/v1.0.0) (2015-03-05)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre6...v1.0.0)

**Closed issues:**

- Throw early if requiring a request file doesn't define the expected function [\#29](https://github.com/lanej/cistern/issues/29)

## [v1.0.1.pre6](https://github.com/lanej/cistern/tree/v1.0.1.pre6) (2015-02-28)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre5...v1.0.1.pre6)

## [v1.0.1.pre5](https://github.com/lanej/cistern/tree/v1.0.1.pre5) (2015-02-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre4...v1.0.1.pre5)

## [v1.0.1.pre4](https://github.com/lanej/cistern/tree/v1.0.1.pre4) (2015-02-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre3...v1.0.1.pre4)

## [v1.0.1.pre3](https://github.com/lanej/cistern/tree/v1.0.1.pre3) (2015-02-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre2...v1.0.1.pre3)

## [v1.0.1.pre2](https://github.com/lanej/cistern/tree/v1.0.1.pre2) (2015-02-12)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.11.2...v1.0.1.pre2)

## [v0.11.2](https://github.com/lanej/cistern/tree/v0.11.2) (2014-11-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.1.pre1...v0.11.2)

**Merged pull requests:**

- 75% fewer Symbol\#to\_s calls in merge\_attributes [\#44](https://github.com/lanej/cistern/pull/44) ([jlindley](https://github.com/jlindley))

## [v1.0.1.pre1](https://github.com/lanej/cistern/tree/v1.0.1.pre1) (2014-10-21)
[Full Changelog](https://github.com/lanej/cistern/compare/v1.0.0.pre...v1.0.1.pre1)

## [v1.0.0.pre](https://github.com/lanej/cistern/tree/v1.0.0.pre) (2014-10-21)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.11.2.pre2...v1.0.0.pre)

## [v0.11.2.pre2](https://github.com/lanej/cistern/tree/v0.11.2.pre2) (2014-10-21)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.11.1...v0.11.2.pre2)

## [v0.11.1](https://github.com/lanej/cistern/tree/v0.11.1) (2014-10-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.11.0...v0.11.1)

**Implemented enhancements:**

- keep track of dirty attributes [\#8](https://github.com/lanej/cistern/issues/8)

**Fixed bugs:**

- keep track of dirty attributes [\#8](https://github.com/lanej/cistern/issues/8)

## [v0.11.0](https://github.com/lanej/cistern/tree/v0.11.0) (2014-09-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.10.2...v0.11.0)

## [v0.10.2](https://github.com/lanej/cistern/tree/v0.10.2) (2014-09-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.10.1...v0.10.2)

## [v0.10.1](https://github.com/lanej/cistern/tree/v0.10.1) (2014-09-12)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.10.0...v0.10.1)

## [v0.10.0](https://github.com/lanej/cistern/tree/v0.10.0) (2014-09-09)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.9.2...v0.10.0)

## [v0.9.2](https://github.com/lanej/cistern/tree/v0.9.2) (2014-08-29)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.9.1...v0.9.2)

## [v0.9.1](https://github.com/lanej/cistern/tree/v0.9.1) (2014-08-12)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.9.0...v0.9.1)

## [v0.9.0](https://github.com/lanej/cistern/tree/v0.9.0) (2014-06-17)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.8.0...v0.9.0)

**Merged pull requests:**

- refactor attribute definition [\#43](https://github.com/lanej/cistern/pull/43) ([jacobo](https://github.com/jacobo))

## [v0.8.0](https://github.com/lanej/cistern/tree/v0.8.0) (2014-06-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.7.1...v0.8.0)

**Merged pull requests:**

- add Cistern::Hash\#stringify\_keys [\#42](https://github.com/lanej/cistern/pull/42) ([thommahoney](https://github.com/thommahoney))

## [v0.7.1](https://github.com/lanej/cistern/tree/v0.7.1) (2014-05-18)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.7.0...v0.7.1)

## [v0.7.0](https://github.com/lanej/cistern/tree/v0.7.0) (2014-05-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/lanej/cistern/tree/v0.6.0) (2014-04-29)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.10...v0.6.0)

**Merged pull requests:**

- set default values on models [\#39](https://github.com/lanej/cistern/pull/39) ([ehowe](https://github.com/ehowe))

## [v0.5.10](https://github.com/lanej/cistern/tree/v0.5.10) (2014-04-16)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.9...v0.5.10)

**Merged pull requests:**

- dont define methods that already exist [\#41](https://github.com/lanej/cistern/pull/41) ([ehowe](https://github.com/ehowe))

## [v0.5.9](https://github.com/lanej/cistern/tree/v0.5.9) (2014-04-14)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.8...v0.5.9)

**Merged pull requests:**

- add cistern singulars [\#40](https://github.com/lanej/cistern/pull/40) ([alenia](https://github.com/alenia))

## [v0.5.8](https://github.com/lanej/cistern/tree/v0.5.8) (2014-04-04)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.7...v0.5.8)

**Merged pull requests:**

- Boolean attributes get question-mark method too [\#38](https://github.com/lanej/cistern/pull/38) ([ryansouza](https://github.com/ryansouza))

## [v0.5.7](https://github.com/lanej/cistern/tree/v0.5.7) (2014-04-03)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.6...v0.5.7)

## [v0.5.6](https://github.com/lanej/cistern/tree/v0.5.6) (2014-04-02)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.5...v0.5.6)

**Merged pull requests:**

- Track attribute usage for coverage reporting [\#36](https://github.com/lanej/cistern/pull/36) ([ryansouza](https://github.com/ryansouza))
- Add `collection\_path` to Cistern::Service [\#35](https://github.com/lanej/cistern/pull/35) ([ryansouza](https://github.com/ryansouza))

## [v0.5.5](https://github.com/lanej/cistern/tree/v0.5.5) (2014-03-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.4...v0.5.5)

## [v0.5.4](https://github.com/lanej/cistern/tree/v0.5.4) (2014-03-03)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.3...v0.5.4)

**Closed issues:**

- Ruby 2.x Array\#to\_set removed [\#34](https://github.com/lanej/cistern/issues/34)

## [v0.5.3](https://github.com/lanej/cistern/tree/v0.5.3) (2014-03-02)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.2.pre1...v0.5.3)

## [v0.5.2.pre1](https://github.com/lanej/cistern/tree/v0.5.2.pre1) (2014-03-02)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.1...v0.5.2.pre1)

**Merged pull requests:**

- Model fallback inspect should include identity [\#33](https://github.com/lanej/cistern/pull/33) ([ryansouza](https://github.com/ryansouza))

## [v0.5.1](https://github.com/lanej/cistern/tree/v0.5.1) (2014-02-27)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.1.pre2...v0.5.1)

## [v0.5.1.pre2](https://github.com/lanej/cistern/tree/v0.5.1.pre2) (2014-02-22)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.5.1.pre1...v0.5.1.pre2)

## [v0.5.1.pre1](https://github.com/lanej/cistern/tree/v0.5.1.pre1) (2014-02-22)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.3.2...v0.5.1.pre1)

**Merged pull requests:**

- Fix bugs with Collection loaded status [\#31](https://github.com/lanej/cistern/pull/31) ([ryansouza](https://github.com/ryansouza))
- Make the not implemented error helpful [\#28](https://github.com/lanej/cistern/pull/28) ([ryansouza](https://github.com/ryansouza))

## [v0.3.2](https://github.com/lanej/cistern/tree/v0.3.2) (2013-10-13)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.4.0...v0.3.2)

**Merged pull requests:**

- check for global constant instead of accidentily autoloading [\#27](https://github.com/lanej/cistern/pull/27) ([jhsu](https://github.com/jhsu))

## [v0.4.0](https://github.com/lanej/cistern/tree/v0.4.0) (2013-10-03)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.3.1...v0.4.0)

**Merged pull requests:**

- drilling [\#26](https://github.com/lanej/cistern/pull/26) ([lanej](https://github.com/lanej))

## [v0.3.1](https://github.com/lanej/cistern/tree/v0.3.1) (2013-09-25)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.3.0...v0.3.1)

**Closed issues:**

- Two attributes with the same alias [\#23](https://github.com/lanej/cistern/issues/23)

**Merged pull requests:**

- Allow same aliases for multiple attributes, fixes \#23 [\#25](https://github.com/lanej/cistern/pull/25) ([manuelmeurer](https://github.com/manuelmeurer))
- Simplify casting boolean attributes [\#24](https://github.com/lanej/cistern/pull/24) ([manuelmeurer](https://github.com/manuelmeurer))

## [v0.3.0](https://github.com/lanej/cistern/tree/v0.3.0) (2013-07-29)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.2.3...v0.3.0)

## [v0.2.3](https://github.com/lanej/cistern/tree/v0.2.3) (2013-07-17)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.2.2...v0.2.3)

**Fixed bugs:**

- override == for Cistern::Collection [\#17](https://github.com/lanej/cistern/issues/17)

**Merged pull requests:**

- Cistern::Collection lazy\_load size,count,to\_s [\#18](https://github.com/lanej/cistern/pull/18) ([jacobo](https://github.com/jacobo))

## [v0.2.2](https://github.com/lanej/cistern/tree/v0.2.2) (2013-06-05)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.2.1...v0.2.2)

**Fixed bugs:**

- awesome\_print formatter excludes attributes of the Cistern::Model type [\#13](https://github.com/lanej/cistern/issues/13)
- formatting abstraction for collection AND models [\#11](https://github.com/lanej/cistern/issues/11)
- first and last need to be wrapped around the lazy load [\#9](https://github.com/lanej/cistern/issues/9)

**Closed issues:**

- write a gem description [\#15](https://github.com/lanej/cistern/issues/15)
- Update README [\#12](https://github.com/lanej/cistern/issues/12)

**Merged pull requests:**

- readme [\#16](https://github.com/lanej/cistern/pull/16) ([shaiguitar](https://github.com/shaiguitar))

## [v0.2.1](https://github.com/lanej/cistern/tree/v0.2.1) (2013-01-17)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.2.0...v0.2.1)

## [v0.2.0](https://github.com/lanej/cistern/tree/v0.2.0) (2013-01-17)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.1.4...v0.2.0)

## [v0.1.4](https://github.com/lanej/cistern/tree/v0.1.4) (2012-11-30)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.1.3...v0.1.4)

## [v0.1.3](https://github.com/lanej/cistern/tree/v0.1.3) (2012-11-30)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.1.2...v0.1.3)

## [v0.1.2](https://github.com/lanej/cistern/tree/v0.1.2) (2012-11-30)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.1.1...v0.1.2)

## [v0.1.1](https://github.com/lanej/cistern/tree/v0.1.1) (2012-09-19)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/lanej/cistern/tree/v0.1.0) (2012-09-19)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.0.3...v0.1.0)

**Implemented enhancements:**

- plugin data types for parsing [\#10](https://github.com/lanej/cistern/issues/10)
- remove formatador, inspect engine abstraction [\#7](https://github.com/lanej/cistern/issues/7)

## [v0.0.3](https://github.com/lanej/cistern/tree/v0.0.3) (2012-07-21)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.0.2...v0.0.3)

**Fixed bugs:**

- preserve nil on type: string [\#6](https://github.com/lanej/cistern/issues/6)
- attribute type: integer, preserve nil [\#5](https://github.com/lanej/cistern/issues/5)

## [v0.0.2](https://github.com/lanej/cistern/tree/v0.0.2) (2012-06-15)
[Full Changelog](https://github.com/lanej/cistern/compare/v0.0.1...v0.0.2)

**Fixed bugs:**

- Cistern::Model\#reload does not handle nil data [\#2](https://github.com/lanej/cistern/issues/2)
- missing formatador require statement [\#1](https://github.com/lanej/cistern/issues/1)

## [v0.0.1](https://github.com/lanej/cistern/tree/v0.0.1) (2012-06-11)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*