# Pin npm packages by running ./bin/importmap

pin_all_from Hotdocs::Engine.root.join("app/assets/javascript/controllers"), to: "controllers", under: "hotdocs/controllers", preload: "hotdocs"
