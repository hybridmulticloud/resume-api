const synthetics = require('Synthetics');
const page = await synthetics.getPage();
const res = await page.goto("https://${aws_cloudfront_distribution.main.domain_name}", { waitUntil: 'networkidle0' });
if (res.status() !== 200) throw new Error(`Status ${res.status()}`);
