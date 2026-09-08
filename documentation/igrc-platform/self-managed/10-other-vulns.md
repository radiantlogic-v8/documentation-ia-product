# Other vulnerabilities

The vulnerabilities listed on this page are reported exclusively against images built on ChainGuard base images. These are **probable false positives, currently under investigation**, and are tracked separately from the [non applicable vulnerabilities](09-non-applicable-vulns.md) list until they have been confirmed one way or the other.

## Version 3.7.2

| ISSUE SEVERITY | PROBLEM TITLE                                                                                                                                                                                                                    |      CVE       | IMAGE(S)                                                              |
| :------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------: | :--------------------------------------------------------------------- |
| CRITICAL | The source-address critical option in the Permissions returned by an authentication callback was only enforced for the PublicKeyCallback and VerifiedPublicKeyCallback paths, extending the fix for CVE-2026-46595. Permissi... | CVE-2026-56854 | radiantone/ida-etcd-internal:3.5.2-nightly |
| CRITICAL | Issue summary: OpenSSL CMP response validation passed an unexpected response | CVE-2026-63073 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| CRITICAL | Issue summary: ChaCha20-Poly1305 and AES-OCB decryption with an empty | CVE-2026-75803 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | A flaw was found in libxslt where the attribute type, atype, flags are modified in a way that corrupts internal memory management. When XSLT functions, such as the key() process, result in tree fragments, this corruption... | CVE-2025-7425 | radiantone/ida-apisix-internal:3.5.2-nightly |
| HIGH | Issue summary: In a server or client configuration with RFC7250 Raw Public Keys (RPKs) | CVE-2026-14457 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Issue summary: QUIC server may double free QRX (QUIC record layer RX) object | CVE-2026-18798 | radiantone/ida-apisix-internal:3.5.2-nightly |
| HIGH | Parsing an invalid SVCB or HTTPS RR can panic when the size of a parameter value overflows the message buffer. | CVE-2026-46600 | radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Issue summary: Receiving a DTLS record for a future epoch while a handshake | CVE-2026-54874 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | A norm.Iter can enter an infinite loop when handling input containing invalid UTF-8 bytes. | CVE-2026-56852 | radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Previously, after a channel has been established, a malicious peer could send crafted messages that would deadlock the entire connection. | CVE-2026-56855 | radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Issue summary: OpenSSL CMS decryption sizes the key-unwrap output buffer based | CVE-2026-63072 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Issue summary: When OpenSSL processes QUIC traffic from a peer that repeatedly | CVE-2026-63075 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Issue summary: OpenSSL CMP password based protection verification only | CVE-2026-63076 | radiantone/ida-apisix-internal:3.5.2-nightly; radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | Previously, a channel registered in the mux's chanList is not usable until it is established. A malicious peer was able flood the channel's incomingRequests, deadlocking the entire connection. | CVE-2026-78662 | radiantone/ida-etcd-internal:3.5.2-nightly |
| HIGH | gRPC-Go is the Go language implementation of gRPC. Prior to 1.83.1, internal/transport/transport.go stores each fragmented HTTP/2 DATA frame as a separate recvMsg in recvBuffer, so millions of one-byte frames can consume... | CVE-2026-84304 | radiantone/ida-etcd-internal:3.5.2-nightly |
