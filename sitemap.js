const sitemap = require('nextjs-sitemap-generator');
const replace = require('replace-in-file');

console.log('Generating sitemap')
sitemap({
    baseUrl: 'http://localhost',
    pagesDirectory: __dirname + "/pages",
    targetDirectory: 'public/',
    nextConfigPath: __dirname + "/next.config.js",
    ignoredExtensions: [
        'png',
        'jpg'
    ]
});

try {
    //Fix for issue with sitemap generator
    replace.sync({
        files: 'public/sitemap.xml',
        from: 'http://localhost/index',
        to: 'http://localhost/',
    })
}
catch (error) {
    console.error('Error occurred:', error);
}
