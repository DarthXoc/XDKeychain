# XDKeychain

## Summary
This framework provides an easy way to interact with the iOS System Keychain.

To learn more about this project, please visit it on 
[GitHub](https://github.com/DarthXoc/XDKeychain).

## Installation
Simply add XDKeychain via Swift Package Manager to your project... that's it!

## Usage 

### Add data to System Keychain
```
Keychain.add(credential: Keychain.Credential(token: "TOKEN_OR_PASSWORD",
    username: "USERNAME"))
```

### Add data to iCloud Keychain
```
Keychain.updateICloudKeychain(stringPassword: "TOKEN_OR_PASSWORD",
    stringUsername: "USERNAME");
```
```
Keychain.updateICloudKeychain(stringPassword: Keychain.fetchCredential(credentialPart: .Token)!,
    stringUsername: Keychain.fetchCredential(credentialPart: .Username)!
```

### Delete data in System Keychain
```
Keychain.delete()
```

### Fetch token/password from System Keychain
```
Keychain.fetchCredential(credentialPart: .Token)
```

### Fetch username from System Keychain
```
Keychain.fetchCredential(credentialPart: .Username)
```

### Update token/password in System Keychain
```
Keychain.add(credential: Keychain.Credential(token: "TOKEN_OR_PASSWORD",
    username: Keychain.fetchCredential(credentialPart: .Username)!))
```

### Update username in System Keychain
```
Keychain.add(credential: Keychain.Credential(token: Keychain.fetchCredential(credentialPart: .Token)!,
    username: "USERNAME"))
```
