const withCSS = require("@zeit/next-css")
const withOptimizedImages = require("next-optimized-images")
const withFonts = require("next-fonts")
const withOffline = require("next-offline")

const nextConfig = {
    env: {
        REACT_APP_COGNITO_HOST: process.env.REACT_APP_COGNITO_HOST,
        REACT_APP_CLIENT_ID: process.env.REACT_APP_CLIENT_ID,
        REACT_APP_REDIRECT_URL: process.env.REACT_APP_REDIRECT_URL,
        REACT_APP_USER_API_URL: process.env.REACT_APP_USER_API_URL
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