const withCSS = require('@zeit/next-css')
const withOptimizedImages = require('next-optimized-images')
const withFonts = require('next-fonts');

module.exports = withOptimizedImages(withFonts(withCSS({

})))