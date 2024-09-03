# fs-nasa-cfs-osal-integration
NASA OSAL bundle for integration and unit tests

This repository aims in a minimal bundle of NASA cFS components required for executing OSAL's integration and unit tests.

It works similar to the NASA cFS sample mission bundle (https://github.com/nasa/cFS), but excluding applications, libraries and cFS executive components required to a complete mission.

The initial version of this repository was based on NASA cFS sample mission bundle (https://github.com/nasa/cFS) equuleus-rc1 **plus** developments up to 2024-01-31 with the following commit signatures:

```
$ git clone https://github.com/nasa/cFS
$ cd cFS/
$ git checkout a0c35aaeac8363f81ed22b54a10e11b74d503c76
$ git submodule init
$ git submodule update --recursive
[...]
Submodule path 'apps/ci_lab': checked out '4a3e698968281275d8cc3551873fed688cd085f3'
Submodule path 'apps/sample_app': checked out '2dd3b1cf4218cfce15fda0c4627f278ff56917b3'
Submodule path 'apps/sch_lab': checked out 'dc58baf4f02e8adde0b411c6544c0f43a13de8d0'
Submodule path 'apps/to_lab': checked out 'd9bef53f35253155ff9c3119612a77f28da3fc7d'
Submodule path 'cfe': checked out '3e32c9db76ede64f5e69b0acd72c411d98210dac'
Submodule path 'libs/sample_lib': checked out '83d26957beaf256bbcdff3188a67dc4025726704'
Submodule path 'osal': checked out '403ebba579e41f0f5832b3619de8788973e0cb63'
Submodule path 'psp': checked out '70be39db9259061d3c9aaf1bc3eb8921e8794828'
Submodule path 'tools/cFS-GroundSystem': checked out '821a163729ebd5bb77ce89711929d55ee837204d'
Submodule path 'tools/elf2cfetbl': checked out '2953d8d6e14db014990d3530497c76138cd1590e'
Submodule path 'tools/tblCRCTool': checked out '42de9c416750e5c92575c74755fc4462a49a5b35'


```
