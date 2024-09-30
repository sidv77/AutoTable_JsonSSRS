const http = require('http');
const fs = require('fs');

let html;
let css;
let js;
let ico;
let svg;
let svg1;
let svg2;

fs.readFile('./favicon.ico', function (err, data) {
    if (err) {
        throw err;
    }
    ico = data;
});

fs.readFile('./sort_both.svg', function (err, data) {
    if (err) {
        throw err;
    }
    svg = data;
});
fs.readFile('./sort_down.svg', function (err, data) {
    if (err) {
        throw err;
    }
    svg1 = data;
});
fs.readFile('./sort_up.svg', function (err, data) {
    if (err) {
        throw err;
    }
    svg2 = data;
});
fs.readFile('./index.css', function (err, data) {
    if (err) {
        throw err;
    }
    css = data;
});

fs.readFile('./index.js', function (err, data) {
    if (err) {
        throw err;
    }
    js = data;
});


fs.readFile('./index.html', function (err, data) {
    if (err) {
        throw err;
    }
    html = data;
});


http.createServer((req, res) => {
    res.statusCode = 200;

    if (req.url.indexOf('.js') != -1) {
        res.writeHead(200, { 'Content-Type': 'text/javascript' });
        res.write(js);
        res.end();
        return;
    }

    if (req.url.indexOf('.css') != -1) {
        res.writeHead(200, { 'Content-Type': 'text/css' });
        res.write(css);
        res.end();
        return;
    }

    if (req.url.indexOf('both.svg') != -1) {
        res.writeHead(200, { 'Content-Type': 'image/svg+xml' });
        res.write(svg);
        res.end();
        return;
    }
    if (req.url.indexOf('down.svg') != -1) {
        res.writeHead(200, { 'Content-Type': 'image/svg+xml' });
        res.write(svg1);
        res.end();
        return;
    }		
    if (req.url.indexOf('up.svg') != -1) {
        res.writeHead(200, { 'Content-Type': 'image/svg+xml' });
        res.write(svg2);
        res.end();
        return;
    }

    if (req.url.indexOf('.ico') != -1) {
        res.writeHead(200, { 'Content-Type': 'image/x-icon' });
        res.write(ico);
        res.end();
        return;
    }

    res.writeHeader(200, { "Content-Type": "text/html" });
    res.write(html);
    res.end();

}).listen(3000);


