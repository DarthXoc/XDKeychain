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
Keychain.add(credential: Credential(token: "TOKEN_OR_PASSWORD",
    username: "USERNAME"))
```

### Add data to iCloud Keychain
```
Keychain.updateICloudKeychain(username: "USERNAME",
    password: "TOKEN_OR_PASSWORD",
    publicFqdn: "https://WWW.YOURWEBSITE.COM");
```
```
Keychain.updateICloudKeychain(username: Keychain.fetchCredential(credentialPart: .username)!,
    password: .fetchCredential(credentialPart: .token)!,
    publicFqdn: "https://WWW.YOURWEBSITE.COM");
```

### Delete data in System Keychain
```
Keychain.delete()
```

### Fetch token/password from System Keychain
```
Keychain.fetchCredential(credentialPart: .token)
```

### Fetch username from System Keychain
```
Keychain.fetchCredential(credentialPart: .username)
```

### Update token/password in System Keychain
```
Keychain.add(credential: Credential(token: "TOKEN_OR_PASSWORD",
    username: Keychain.fetchCredential(credentialPart: .username)!))
```

### Update username in System Keychain
```
Keychain.add(credential: Credential(token: Keychain.fetchCredential(credentialPart: .token)!,
    username: "USERNAME"))
```
