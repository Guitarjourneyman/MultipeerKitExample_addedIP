import Foundation

struct MultipeerMessage: Codable {
    static let senderUserInfoKey = CodingUserInfoKey(rawValue: "sender")!
    
    let type: String
    let payload: Any?
    let senderIP: String?   // Include the sender's IP address

    // Modify the initializer to include senderIP
    init(type: String, payload: Any, senderIP: String?) {
        self.type = type
        self.payload = payload
        self.senderIP = senderIP // Set the senderIP
    }

    enum CodingKeys: String, CodingKey {
        case type
        case payload
        case senderIP // Add senderIP to CodingKeys
    }

    private typealias MessageDecoder = (KeyedDecodingContainer<CodingKeys>, Peer) throws -> Any
    private typealias MessageEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void

    private static var decoders: [String: MessageDecoder] = [:]
    private static var encoders: [String: MessageEncoder] = [:]

    static func register<T: Codable>(_ type: T.Type, for typeName: String, closure: @escaping (T, Peer) -> Void) {
        decoders[typeName] = { container, peer in
            let payload = try container.decode(T.self, forKey: .payload)

            DispatchQueue.main.async { closure(payload, peer) }

            return payload
        }

        register(T.self, for: typeName)
    }

    static func register<T: Encodable>(_ type: T.Type, for typeName: String) {
        encoders[typeName] = { payload, container in
            try container.encode(payload as! T, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        // Decode senderIP
        senderIP = try container.decode(String.self, forKey: .senderIP) // Add this line

        let sender = decoder.userInfo[MultipeerMessage.senderUserInfoKey]! as! Peer

        if let decode = Self.decoders[type] {
            payload = try decode(container, sender)
        } else {
            payload = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)

        // Encode senderIP
        if let senderIP = self.senderIP {
            try container.encode(senderIP, forKey: .senderIP) // Add this line
        } else {
            try container.encodeNil(forKey: .senderIP) // Handle nil case
        }

        if let payload = self.payload {
            guard let encode = Self.encoders[type] else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid payload type: \(type).")
                throw EncodingError.invalidValue(self, context)
            }

            try encode(payload, &container)
        } else {
            try container.encodeNil(forKey: .payload)
        }
    }
}

