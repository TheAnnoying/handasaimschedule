import * as cheerio from 'cheerio';
import { $ as bash } from 'bun';
import { CronJob } from 'cron';

const headers = { "Access-Control-Allow-Origin": "*" }

Bun.serve({
	port: 3001,
	routes: {
		'/api/classes': async () => Response.json(Object.keys(await Bun.file('output.json').json()), { headers }),
		'/api/schedule/:class': async (req) =>
			Response.json((await Bun.file('output.json').json())[req.params.class], { headers })
	}
});

const job = CronJob.from({
	cronTime: '0 * * * *',
	onTick: async () => {
		await Bun.sleep(Math.floor(Math.random() * 30 * 60 * 1000));

		console.log('Fetching schedule...');
		await fetchSchedule();
	},
	start: true,
	timeZone: 'Asia/Jerusalem'
});

async function fetchSchedule() {
	const html = await bash`curl -sL "${process.env.SPREADSHEET_URL}" | bsdtar -xOf - '*.html'`.text();
	const $ = cheerio.load(html);

	type Entry = {
		hours: string[];
		subjects: string[];
		teachers: string[];
	};

	interface Schedule {
		[key: string]: Entry[];
	}

	const json: Schedule = {};

	$('thead').remove();
	$('th').remove();

	$('tr').each((_, row) => {
		const cells = $(row).children();
		const first = cells.first().text().trim();
		const second = cells.eq(1).text().trim();

		if (!first && !second) $(row).remove();
		else if (!first && second) $(row).prevAll().remove();
	});

	$('tr').each((rowIndex, row) => {
		const cells = $(row).children();

		cells.each((colIndex, cell) => {
			const cellHTML = ($(cell).html() ?? '').trim().replace(/^<br>|<br>$/g, '');
			if(cellHTML.includes("קרונפלד אילנה")) console.log(cellHTML)
			if (rowIndex === 0 && cellHTML) {
				json[cellHTML] = [];
			} else {
				const index = Object.keys(json)[colIndex - 1];
				if (index && cellHTML) {
					const hours = (cells.first().html() ?? '').trim().split('<br>');
					json[index]?.push({
						hours: [hours[0] ?? '', hours.slice(1).join(' - ')],
						subjects: cellHTML.split('<br>').filter((e, i) => i % 2 !== 0 && e.length),
						teachers: cellHTML.split('<br>').filter((e, i) => i % 2 === 0 && e.length)
					});
				}
			}
		});
	});

	Bun.write('output.json', JSON.stringify(json));
}