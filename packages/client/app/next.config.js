const withCSS = require("@zeit/next-css")
const withOptimizedImages = require("next-optimized-images")
const withFonts = require("next-fonts")
const withOffline = require("next-offline")

const nextConfig = {
    env: {
        REACT_APP_COGNITO_HOST: process.env.REACT_APP_COGNITO_HOST,
        REACT_APP_CLIENT_ID: process.env.REACT_APP_CLIENT_ID,
        REACT_APP_URL: process.env.REACT_APP_URL,
        REACT_APP_USER_API_URL: process.env.REACT_APP_USER_API_URL
    }
}

module.exports = withOffline(withOptimizedImages(withFonts(withCSS(
    nextConfig
))))