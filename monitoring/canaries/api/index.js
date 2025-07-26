const http = require('Synthetics');
const log = require('SyntheticsLogger');

exports.handler = async () => {
  const requestOptions = {
    hostname: data.aws_api_gateway_stage.api_stage.invoke_url.replace('https://', '').replace(`/${var.api_stage_name}`, ''),
    method: 'GET',
    path: `/${var.api_stage_name}/count`,
    headers: { 'Content-Type': 'application/json' }
  };
  const response = await http.executeHttpStep('GetCount', requestOptions);
  if (response.statusCode !== 200) {
    throw new Error(`Expected 200, got ${response.statusCode}`);
  }
  log.info('API responded with 200');
};
