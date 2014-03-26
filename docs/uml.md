# UML architecture diagrams

This is the source for creating diagrams via
http://bramp.github.io/js-sequence-diagrams/

## User

```
Participant Internet
Participant Weak\nFirewall
Participant Wormhole
Participant Strong\nFirewall
Participant Internal\nInfrastructure
Participant Internal\nAAA

Internet->Wormhole: user ssh via 2fa
note over Wormhole: unpriviliged\ncontainerized\nsandbox session
Wormhole->Internet: git fetch/push
Wormhole->Internet: bundle install
Wormhole->Internet: curl ...
Wormhole->Internal\nInfrastructure: ssh via internal mechanism(s)
Internal\nInfrastructure->Internal\nAAA: check auth (pass/fail)
note over Internal\nInfrastructure: user session
Internal\nInfrastructure->Strong\nFirewall: (X) deny outbound
```
