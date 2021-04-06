import Foundation

class Keychain
{
    // MARK: - Enumerations
    
    internal enum CredentialPart
    {
        case Token;
        case Username;
    }
    
    // Define query types
    private enum QueryType
    {
        case Fetch;
        case Update;
    }
    
    // MARK: - Structures
    
    // Define a structure to pass data to the Keychain
    internal struct Credential
    {
        var token: String;
        var username: String;
    }
    
    // MARK: - Variables
    
    // Setup any required variables
    internal static let stringICloudKeychainFqdn: String = "numeroapp.com"; // The public FQDN of your your application; this should be the same as what you entered in your Entitlements file.
    static private let stringService: String = Bundle.main.bundleIdentifier!;
    
    // MARK: - Keychain
    
    /// Adds the specified credentials to the keychain
    @discardableResult internal static func add(credential: Credential) -> Bool
    {
        // Setup the new Keychain item
        let dictKeychainEntry: [CFString: Any] = [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
                                                  kSecAttrAccount: credential.username,
                                                  kSecAttrService: stringService,
                                                  kSecClass: kSecClassGenericPassword,
                                                  kSecValueData: credential.token.data(using: .utf8)!];
        
        // Check to see if an item already exists in Keychain
        if (self.fetch() != nil)
        {
            // Delete the existing Keychain item
            self.delete();
        }
        
        // Attempt to add the entry to the Keychain
        let status: OSStatus = SecItemAdd(dictKeychainEntry as CFDictionary, nil);
        
        // Check to see if the entry was added successfully
        if (status == errSecSuccess)
        {
            return true
        }
        else
        {
            return false;
        }
    }
    
    /// Deletes the specified credentials from the keychain
    @discardableResult internal static func delete() -> Bool
    {
        // Attempt to delete the entry from the Keychain
        let status: OSStatus = SecItemDelete(self.query(queryType: .Update) as CFDictionary)
        
        // Check to see if the entry was deleted successfully
        if (status == errSecSuccess)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /// Fetches the specified credentials from the keychain
    static private func fetch() -> Credential?
    {
        var result: CFTypeRef? = nil;
        
        // Attempt to retreive the entry from the Keychain
        let status: OSStatus = SecItemCopyMatching(self.query(queryType: .Fetch) as CFDictionary, &result);
        
        // Check to see if the fetch completed successfully
        if (status == errSecSuccess)
        {
            return Credential(token: String(data: result?.value(forKey: kSecValueData as String) as? Data ?? Data(), encoding: .utf8) ?? "",
                              username: result?.value(forKey: kSecAttrAccount as String) as? String ?? "");
        }
        else
        {
            return nil;
        }
    }
    
    /// Fetches the specified credential part from the keychain
    internal static func fetchCredential(credentialPart: CredentialPart) -> String?
    {
        let credential: Credential? = self.fetch();
        
        // Check to see if the fetch completed successfully and what credential part was requested
        if (credential != nil && credentialPart == .Token)
        {
            return credential!.token;
        }
        else if (credential != nil && credentialPart == .Username)
        {
            return credential!.username;
        }
        
        return nil;
    }
    
    /// Queries the keychain to retreive the credentials
    static private func query(queryType: QueryType) -> [CFString: Any]
    {
        // Check to see which type of query is being requested
        if (queryType == .Fetch)
        {
            return [kSecAttrService: stringService,
                    kSecClass: kSecClassGenericPassword,
                    kSecMatchLimit: kSecMatchLimitOne,
                    kSecReturnAttributes: true,
                    kSecReturnData: true];
        }
        else if (queryType == .Update)
        {
            return [kSecAttrService: stringService,
                    kSecClass: kSecClassGenericPassword];
        }
        
        return [:];
    }
    
    /// Updates the credentials stored in iCloud Keychain (seperate from the System Keychain)
    internal static func updateICloudKeychain(stringPassword: String?, stringUsername: String)
    {
        // Attempt to insert, update or delete the credential
        SecAddSharedWebCredential(stringICloudKeychainFqdn as CFString,
                                  stringUsername as CFString,
                                  stringPassword as CFString?,
                                  { (error: CFError?) in
                                  // The password was either saved to iCloud Keychain or it wasn't. If it failed, there's no reason to bother the user with it as there's nothing we can do and we don't want to send the app into a save-failure loop
        });
    }
}
