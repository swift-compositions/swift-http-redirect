import HTTP_Redirect
import HTTP_Standard
import Server
import Testing

extension Redirect {
    @Suite("HTTP redirect policies")
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}

        fileprivate static func headers(_ fields: [(String, String)]) -> HTTP.Headers {
            HTTP.Headers(
                fields.map { name, value in
                    HTTP.Header.Field(name: .init(name), value: .init(unchecked: value))
                }
            )
        }
    }
}

extension Redirect.Test.Unit {
    @Test
    func `canonical host`() async throws(Server.Error) {
        let middleware = Redirect.Canonical(host: "www.example.com")
        let request = Server.Request(
            method: .get,
            path: ["docs", "intro"],
            query: "page=2",
            headers: Redirect.Test.headers([
                ("Host", "example.com"),
                ("X-Forwarded-Proto", "https"),
            ])
        )

        let response = try await middleware.intercept(request) { _ in
            .status(.ok)
        }

        #expect(response.status == .movedPermanently)
        // swift-linter:disable:next raw value access
        // REASON: the test verifies the serialized Location header at the protocol boundary.
        #expect(
            response.headers.first("Location")?.rawValue
                == "https://www.example.com/docs/intro?page=2"
        )
    }

    @Test
    func `canonical host pass through`() async throws(Server.Error) {
        let middleware = Redirect.Canonical(host: "www.example.com")
        let request = Server.Request(
            method: .get,
            path: ["docs"],
            headers: Redirect.Test.headers([("Host", "www.example.com")])
        )

        let response = try await middleware.intercept(request) { _ in
            .status(.noContent)
        }

        #expect(response.status == .noContent)
    }

    @Test
    func `HTTPS redirect`() async throws(Server.Error) {
        let middleware = Redirect.HTTPS(on: true)
        let request = Server.Request(
            method: .get,
            path: ["login"],
            headers: Redirect.Test.headers([
                ("Host", "example.com"),
                ("X-Forwarded-Proto", "http"),
            ])
        )

        let response = try await middleware.intercept(request) { _ in
            .status(.ok)
        }

        #expect(response.status == .movedPermanently)
        // swift-linter:disable:next raw value access
        // REASON: the test verifies the serialized Location header at the protocol boundary.
        #expect(response.headers.first("Location")?.rawValue == "https://example.com/login")
    }

    @Test
    func `HTTPS pass through`() async throws(Server.Error) {
        let middleware = Redirect.HTTPS(on: true)
        let request = Server.Request(
            method: .get,
            path: [],
            headers: Redirect.Test.headers([
                ("Host", "example.com"),
                ("X-Forwarded-Proto", "https"),
            ])
        )

        let response = try await middleware.intercept(request) { _ in
            .status(.ok)
        }

        #expect(response.status == .ok)
        // swift-linter:disable:next raw value access
        // REASON: the test verifies the RFC 6797 field serialization at the protocol boundary.
        #expect(
            response.headers.first("Strict-Transport-Security")?.rawValue
                == "max-age=31536000; includeSubDomains"
        )
    }
}
