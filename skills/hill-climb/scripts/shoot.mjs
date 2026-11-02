// Screenshot one or more URLs at several viewports, for a hill-climb round.
// Run from the project root, so Playwright resolves from the project.
//
//   node shoot.mjs <outdir> <url> [<url>...]
//
// Environment:
//   VIEWPORTS  comma list of WxH        (default 1440x800,1280x600)
//   PREFIX     file-name prefix         (default "shot", e.g. before, round-3)
//   FULL=1     also take a full-page shot per viewport
//   WAIT       CSS selector to wait for before shooting (optional)
//   SETTLE     ms to wait after load    (default 1500)
//
// Output: <outdir>/<prefix>-<n>-<W>x<H>[-full].jpg, and one line per shot with
// the page height and whether the page scrolls horizontally.
import { mkdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';

const require = createRequire(path.join(process.cwd(), 'noop.js'));
let chromium;
try {
  ({ chromium } = require('@playwright/test'));
} catch {
  try {
    ({ chromium } = require('playwright'));
  } catch {
    console.error('Playwright not found in this project. Install @playwright/test or playwright.');
    process.exit(1);
  }
}

const [out, ...urls] = process.argv.slice(2);
if (!out || urls.length === 0) {
  console.error('usage: node shoot.mjs <outdir> <url> [<url>...]');
  process.exit(2);
}
mkdirSync(out, { recursive: true });

const viewports = (process.env.VIEWPORTS ?? '1440x800,1280x600')
  .split(',')
  .map((v) => v.split('x').map(Number));
const prefix = process.env.PREFIX ?? 'shot';
const settle = Number(process.env.SETTLE ?? 1500);

const browser = await chromium.launch();
try {
  for (const [i, url] of urls.entries()) {
    for (const [width, height] of viewports) {
      const page = await browser.newPage({ viewport: { width, height } });
      const errors = [];
      page.on('console', (m) => m.type() === 'error' && errors.push(m.text()));
      await page.goto(url, { waitUntil: 'networkidle' }).catch((e) => errors.push(String(e)));
      if (process.env.WAIT) await page.locator(process.env.WAIT).first().waitFor({ timeout: 30000 });
      await page.waitForTimeout(settle);
      const base = `${out}/${prefix}-${i + 1}-${width}x${height}`;
      await page.screenshot({ path: `${base}.jpg`, type: 'jpeg', quality: 70 });
      if (process.env.FULL === '1')
        await page.screenshot({ path: `${base}-full.jpg`, type: 'jpeg', quality: 70, fullPage: true });
      const m = await page.evaluate(() => ({
        h: document.documentElement.scrollHeight,
        hscroll: document.documentElement.scrollWidth > window.innerWidth,
      }));
      console.log(
        `${base}.jpg  height=${m.h}px${m.hscroll ? '  HORIZONTAL-SCROLL' : ''}` +
          (errors.length ? `  console-errors=${errors.length}: ${errors[0].slice(0, 120)}` : ''),
      );
      await page.close();
    }
  }
} finally {
  await browser.close();
}
