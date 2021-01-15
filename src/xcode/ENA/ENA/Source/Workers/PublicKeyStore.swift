//
// 🦠 Corona-Warn-App
//

import Foundation
import CryptoKit

enum KeyError: Error {
	/// It was not possible to create the base64 encoded data from the public key string
	case encodingError
	/// It was not possible to map the provided bundleID to a matching public key
	case environmentError
	/// It was not possible to read the plist containing the public keys
	case plistError
}

extension Data {
	init(staticBase64Encoded: StaticString) {
		// swiftlint:disable:next force_unwrapping
		self.init(base64Encoded: "\(staticBase64Encoded)")!
	}
}

extension P256.Signing.PublicKey {
	init(staticBase64Encoded: StaticString) {
		// swiftlint:disable:next force_try
		try! self.init(rawRepresentation: Data(staticBase64Encoded: staticBase64Encoded))
	}
}

enum PublicKeyEnv {
	case production
	case development

	/// Returns the string representation of the PK.
	///
	/// We don't want to rely on `rawValue` but make accessing the key an explicit action.
	var stringRepresentation: StaticString {
		switch self {
		case .production: return
			"errtUx7t4g9VQ5huiRCLP14N+QadrIYS9/P0Fcd2NwAJDHkWSuhrhvZQV01F0sGshJ+qnvjf9n8Pxe6/wgaD9A=="
		case .development: return
			"errtUx7t4g9VQ5huiRCLP14N+QadrIYS9/P0Fcd2NwAJDHkWSuhrhvZQV01F0sGshJ+qnvjf9n8Pxe6/wgaD9A=="
		}
	}
}

typealias PublicKeyProvider = () -> P256.Signing.PublicKey
typealias PublicKeyFromStringProvider = (StaticString) -> PublicKeyProvider
typealias PublicKeyProviderFromActiveCompilationConditions = () -> PublicKeyProvider
typealias PublicKeyProviderFromEnv = (PublicKeyEnv) -> PublicKeyProvider

private let DefaultPublicKeyFromEnvProvider: PublicKeyProviderFromEnv = { env in
	return DefaultPublicKeyFromString(env.stringRepresentation)
}

let DefaultPublicKeyFromString: PublicKeyFromStringProvider = { pk in
	return { P256.Signing.PublicKey(staticBase64Encoded: pk) }
}

let DefaultPublicKeyProvider: PublicKeyProvider = {
	#if USE_DEV_PK_FOR_SIG_VERIFICATION
	return DefaultPublicKeyFromEnvProvider(.development)
	#else
	return DefaultPublicKeyFromEnvProvider(.production)
	#endif
}()
