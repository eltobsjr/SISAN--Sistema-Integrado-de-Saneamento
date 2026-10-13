const { chromium } = require('playwright-core');

const BASE = 'http://localhost:8099';
const OUT = '/home/eltobsjr/dev/pessoal/sisan/build/pw/shots';

async function abrir({ geo } = {}) {
  const browser = await chromium.launch({ executablePath: '/usr/bin/google-chrome', headless: true });
  const context = await browser.newContext({
    viewport: { width: 412, height: 892 },
    deviceScaleFactor: 2,
    locale: 'pt-BR',
    geolocation: geo,
    permissions: geo ? ['geolocation'] : [],
  });
  const page = await context.newPage();
  await page.goto(BASE, { waitUntil: 'load' });
  await page.waitForTimeout(6000);
  await semantica(page);
  return { browser, page };
}

// Liga a árvore de acessibilidade do Flutter web (vira DOM consultável).
async function semantica(page) {
  await page.evaluate(() => {
    const b = document.querySelector('flt-semantics-placeholder');
    if (b) b.click();
  });
  await page.waitForTimeout(800);
}

async function textos(page) {
  return page.evaluate(() =>
    [...document.querySelectorAll('flt-semantics, input, textarea')]
      .map((e) => `${e.tagName.toLowerCase()} role=${e.getAttribute('role') || ''} label=${(e.getAttribute('aria-label') || e.textContent || '').trim().slice(0, 60)}`)
      .filter((t) => !t.endsWith('label='))
  );
}

// Menor nó de semântica cujo texto começa com [texto] (o mais específico).
async function caixa(page, texto, { depoisDeY = -1 } = {}) {
  return page.evaluate(({ texto, depoisDeY }) => {
    let melhor = null;
    for (const e of document.querySelectorAll('flt-semantics, input')) {
      const t = (e.getAttribute('aria-label') || e.textContent || '').trim();
      if (!t.startsWith(texto)) continue;
      const r = e.getBoundingClientRect();
      if (r.width === 0 || r.height === 0 || r.y < depoisDeY) continue;
      if (!melhor || r.width * r.height < melhor.w * melhor.h) melhor = { x: r.x, y: r.y, w: r.width, h: r.height };
    }
    return melhor;
  }, { texto, depoisDeY });
}

async function clicar(page, texto, opts = {}) {
  let b = null;
  for (let i = 0; i < 10 && !b; i++) {
    b = await caixa(page, texto, opts);
    if (!b) { await page.waitForTimeout(1000); await semantica(page); }
  }
  if (!b) throw new Error('não achei: ' + texto);
  await page.mouse.click(b.x + b.w / 2, b.y + b.h / 2);
  await page.waitForTimeout(1800);
  await semantica(page);
}

async function rolarAte(page, texto, topo = 90) {
  for (let i = 0; i < 30; i++) {
    const b = await caixa(page, texto);
    if (b && b.y >= topo - 10 && b.y <= topo + 60) return;
    const dy = b ? Math.max(Math.min(b.y - topo, 500), -500) : 400;
    await page.mouse.move(206, 450);
    await page.mouse.wheel(0, dy);
    await page.waitForTimeout(600);
    await semantica(page);
  }
}

async function fechar(page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(800);
}

async function login(page, email) {
  const inputs = page.locator('input');
  for (let i = 0; i < 20 && (await inputs.count()) < 2; i++) {
    await page.waitForTimeout(1000);
    await semantica(page);
  }
  await inputs.nth(0).fill(email);
  await inputs.nth(1).fill(process.env.SENHA_DEMO);
  await clicar(page, 'Entrar');
  await page.waitForTimeout(4000);
  await semantica(page);
}

async function foto(page, nome) {
  await page.mouse.move(411, 300);
  await page.waitForTimeout(1800);
  await page.screenshot({ path: `${OUT}/${nome}.jpg`, type: 'jpeg', quality: 90 });
  console.log('ok', nome);
}

module.exports = { abrir, semantica, textos, caixa, clicar, rolarAte, fechar, login, foto, BASE };
