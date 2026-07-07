const API_URL =
  'https://implement.sinergiteknologi.co.id/VenusCRMServices/mobileservices.asmx';

function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, SOAPAction');
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

module.exports = async (req, res) => {
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const body = await readBody(req);
    const soapAction = req.headers.soapaction || req.headers.SOAPAction;

    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        SOAPAction: soapAction || '',
      },
      body,
    });

    const text = await response.text();
    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
    return res.status(response.status).send(text);
  } catch (error) {
    return res.status(500).json({ error: String(error) });
  }
};
