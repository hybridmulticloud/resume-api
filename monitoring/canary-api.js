const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const url = "https://${aws_api_gateway_rest_api.main.execution_arn}/${var.api_stage_name}/UpdateVisitorCount";
const res = await synthetics.executeHttpStep('post-count', {
  url,
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({})
});
if (res.statusCode !== 200) throw new Error(`Status ${res.statusCode}`);
