import Foundation

public class Keychain
{
    // MARK: - Enumerations
    
    // Define credential parts
    public enum CredentialPart: Int
    {
        case token = 1
        case username = 0
    }
    
    // Define query types
    private enum QueryType: Int
    {
        case fetch = 0
        case update = 1
    }
    
    // MARK: - Structures
    
    /// Define a structure to pass data to the Keychain
    public struct Credential
    {
        /// The token or password
        var token: String
        
        /// The username
        var username: String
        
        public init(username: String, token: String) {
            self.token = token
            self.username = username
        }
    }
    
    // MARK: - Variables
    
    // Setup any required variables
    static private let stringService: String = Bundle.main.bundleIdentifier!
    
    // MARK: - Keychain
    
    /// Adds the specified credentials to the system keychain
    @discardableResult public static func add(credential: Credential) -> Bool
    {
        // Setup the new Keychain item
        let dictKeychainEntry: [CFString: Any] = [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
                                                  kSecAttrAccount: credential.username,
                                                  kSecAttrService: stringService,
                                                  kSecClass: kSecClassGenericPassword,
                                                  kSecValueData: credential.token.data(using: .utf8)!]
        
        // Check to see if an item already exists in Keychain
        if (self.fetch() != nil) {
            // Delete the existing Keychain item
            self.delete()
        }
        
        // Attempt to add the entry to the Keychain
        let status: OSStatus = SecItemAdd(dictKeychainEntry as CFDictionary, nil)
        
        // Check to see if the entry was added successfully
        if (status == errSecSuccess) {
            return true
        } else {
            return false
        }
    }
    
    /// Deletes any stored credentials from the system keychain
    @discardableResult public static func delete() -> Bool
    {
        // Attempt to delete the entry from the Keychain
        let status: OSStatus = SecItemDelete(self.query(queryType: .update) as CFDictionary)
        
        // Check to see if the entry was deleted successfully
        if (status == errSecSuccess) {
            return true
        } else {
            return false
        }
    }
    
    /// Fetches the specified credentials from the system keychain
    public static func fetch() -> Credential?
    {
        var result: CFTypeRef? = nil
        
        // Attempt to retreive the entry from the Keychain
        let status: OSStatus = SecItemCopyMatching(self.query(queryType: .fetch) as CFDictionary, &result)
        
        // Check to see if the fetch completed successfully
        if (status == errSecSuccess) {
            return Credential(username: result?.value(forKey: kSecAttrAccount as String) as? String ?? "",
                              token: String(data: result?.value(forKey: kSecValueData as String) as? Data ?? Data(), encoding: .utf8) ?? "")
        } else {
            return nil
        }
    }
    
    /// Fetches the specified credential part from the system keychain
    public static func fetchCredential(credentialPart: CredentialPart) -> String?
    {
        let credential: Credential? = self.fetch()
        
        // Check to see if the fetch completed successfully and what credential part was requested
        if (credential != nil && credentialPart == .token) {
            return credential!.token
        } else if (credential != nil && credentialPart == .username) {
            return credential!.username
        }
        
        return nil
    }
    
    /// Queries the system keychain to retreive the credentials
    private static func query(queryType: QueryType) -> [CFString: Any]
    {
        // Check to see which type of query is being requested
        if (queryType == .fetch) {
            return [kSecAttrService: stringService,
                    kSecClass: kSecClassGenericPassword,
                    kSecMatchLimit: kSecMatchLimitOne,
                    kSecReturnAttributes: true,
                    kSecReturnData: true]
        } else if (queryType == .update) {
            return [kSecAttrService: stringService,
                    kSecClass: kSecClassGenericPassword]
        }
        
        return [:]
    }
    
    /// Updates the credentials stored in iCloud Keychain (seperate from the System Keychain). The public FQDN of your your application should be the same as what you entered in your Entitlements file.
    public static func updateICloudKeychain(username stringUsername: String, password stringPassword: String?, publicFqdn stringICloudKeychainFqdn: String)
    {
        // Attempt to insert, update or delete the credential
        SecAddSharedWebCredential(stringICloudKeychainFqdn as CFString,
                                  stringUsername as CFString,
                                  stringPassword as CFString?,
                                  { (error: CFError?) in
                                  // The password was either saved to iCloud Keychain or it wasn't. If it failed, there's no reason to bother the user with it as there's nothing we can do and we don't want to send the app into a save-failure loop
        })
    }
}
