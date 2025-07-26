const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

exports.handler = async () => {
  const page = await synthetics.getPage();
  await page.goto(`https://${data.aws_cloudfront_distribution.spa.domain_name}/`, { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('h1');  // adjust to your homepage’s key element
  log.info('Homepage loaded successfully');
};
