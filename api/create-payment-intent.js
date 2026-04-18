// api/create-payment-intent.js
// Cette fonction tourne côté serveur sur Vercel — elle crée la transaction Stripe

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const Stripe = (await import('stripe')).default
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)

  try {
    const { amount, cart, userId } = req.body

    const paymentIntent = await stripe.paymentIntents.create({
      amount,           // en centimes (ex: 4500 = 45,00 €)
      currency: 'eur',
      metadata: {
        userId:    userId ?? 'anonymous',
        itemCount: cart?.length ?? 0,
      },
    })

    res.status(200).json({ clientSecret: paymentIntent.client_secret })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
}
