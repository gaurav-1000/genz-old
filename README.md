# GenZ

Dating the new way

[Documentation](/doc/main.md)

## Build

```zsh
$ flutter build ipa --release --no-tree-shake-icons
$ flutter build appbundle --release --no-tree-shake-icons
```

## Generate locales

```zsh
# To active get_cli
$ dart pub global activate get_cli

# Generate locales
$ get generate locales assets/locales
```

## Fix Pods

```zsh
$ pod update Firebase/CoreOnly purchases_flutter Firebase/Crashlytics
```

Apple Sandbox
genz@sandbox.com
Loaded12