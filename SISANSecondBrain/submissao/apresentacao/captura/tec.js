const L = require('./lib');
(async () => {
  const { browser, page } = await L.abrir();
  await L.login(page, 'tecnico1@sisan.com');
  await L.foto(page, 'tec_home');
  await L.clicar(page, 'Ordens'); await page.waitForTimeout(3000);
  await L.foto(page, 'tec_ordens');
  await browser.close();
})().catch((e) => { console.error(e.message); process.exit(1); });
