const withCSS = require("@zeit/next-css")
const withOptimizedImages = require("next-optimized-images")
const withFonts = require("next-fonts")
const glob = require("glob-all")
const PurgecssPlugin = require("purgecss-webpack-plugin")
const withOffline = require("next-offline")
const path = require("path")

const nextConfig = {
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
                    /sticky/
                ],
            })
        )
        return config
    }
}

module.exports = withOffline(withOptimizedImages(withFonts(withCSS(
    nextConfig
))))