# swift-http-redirect

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Two `Server` middlewares that permanently redirect requests to HTTPS and to a canonical host, attaching a Strict-Transport-Security header once a request already arrives over HTTPS.

---

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-foundations/swift-http-redirect.git",
        branch: "main"
    )
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "HTTP Redirect", package: "swift-http-redirect")
    ]
)
```

The package publishes no tags yet, so the dependency is pinned to `main`.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md).
