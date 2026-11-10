// The module's default site program, used when the site selects it with
// `[build] entry = { module = "<alias>" }`. A site that customizes the
// theme writes its own entry calling the same `render-site` with arguments.

#import "lib.typ": render-site
#render-site()
