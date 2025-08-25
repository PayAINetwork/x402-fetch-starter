import 'dotenv/config';

// The upstream sync will map the official example into this folder.
// This fallback shows a minimal shape using wrapFetchWithPayment.
// It will be replaced on sync if upstream provides example code.
async function main(): Promise<void> {
  const paidUrl = process.env.PAID_URL;
  const apiKey = process.env.X402_API_KEY;

  if (!paidUrl || !apiKey) {
    console.error('Please set PAID_URL and X402_API_KEY in your .env');
    process.exit(1);
  }

  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { wrapFetchWithPayment } = await import('x402-fetch');
  const paidFetch = wrapFetchWithPayment(fetch, { paidUrl, apiKey });

  const response = await paidFetch(paidUrl);
  console.log('Response status:', response.status);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});


