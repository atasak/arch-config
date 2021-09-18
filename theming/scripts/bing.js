#! /usr/bin/node

const got = require('got');
const fs = require('fs');

async function main() {
    if (process.argv.length < 3) {
        console.log("Usage: bing.js <working dir> <offset>");
        return 1;
    }
    const themingDir = process.argv[2];
    const offset = parseInt(process.argv[3]);
	const response = await got(`https://www.bing.com/HPImageArchive.aspx?format=js&idx=${offset}&n=1`);
	const json = JSON.parse(response.body);
	const imgUrl = `https://bing.com/${json.images[0].url}`;
	const img = await got(imgUrl);
	fs.writeFileSync(`${themingDir}/img/wallpaper.jpg`, img.rawBody);
}

main();
