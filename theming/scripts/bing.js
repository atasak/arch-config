#! /usr/bin/node

const got = require('got');
const fs = require('fs');

async function main() {
	const response = await got('https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1');
	const json = JSON.parse(response.body);
	const imgUrl = `https://bing.com/${json.images[0].url}`;
	const img = await got(imgUrl);
	fs.writeFileSync(`${process.argv[2]}/img/wallpaper.jpg`, img.rawBody);
}

main();
