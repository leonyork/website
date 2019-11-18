const withCSS = require("@zeit/next-css")
const withOptimizedImages = require("next-optimized-images")
const withFonts = require("next-fonts")
const glob = require("glob-all")
const PurgecssPlugin = require("purgecss-webpack-plugin")
const withOffline = require("next-offline")

const nextConfig = {
    env: {
        REACT_APP_COGNITO_HOST: process.env.REACT_APP_COGNITO_HOST,
        REACT_APP_CLIENT_ID: process.env.REACT_APP_CLIENT_ID,
        REACT_APP_REDIRECT_URL: process.env.REACT_APP_REDIRECT_URL
    },

    webpack: (config) => {
        config.plugins.push(
            new PurgecssPlugin({
                paths: glob.sync([
                    "pages/*.js",
                    "components/*.js"
                ]),
                whitelistPatterns: [
                    /nav/,
                    /^container/,
                    /^jumbotron/,
                    /^collapse/,
                    /^show/,
                    /bg/,
                    /sticky/,
                    /^btn/
                ],
            })
        )
        return config
    },

    workboxOpts: {
        globPatterns: ["public/**/*"],
        globDirectory: ".",
        modifyURLPrefix: {
            "public/": "/",
        },
        runtimeCaching: [
            {
                urlPattern: /^https?.*/,
                handler: "NetworkFirst",
                options: {
                    cacheName: "offlineCache",
                    expiration: {
                        maxEntries: 200
                    }
                }
            }
        ]
    }
}

module.exports = withOffline(withOptimizedImages(withFonts(withCSS(
    nextConfig
))))