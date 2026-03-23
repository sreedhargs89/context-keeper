# Project: my-saas-app
> Path: /Users/you/dev/my-saas-app
> Repo: https://github.com/you/my-saas-app.git
> Last Session: 2026-03-20 | Sessions: 12

## What This Is
A SaaS app with Stripe-powered subscription payments. Built for indie hackers who want a ready-to-deploy billing setup.

## Tech Stack
Next.js, Neon (Postgres), Clerk (auth), Stripe

## Current Goal
Launch payment flow with Stripe — get users through checkout and into a paid plan

## Where I Left Off
- Debugging webhook signature verification in app/api/webhooks/stripe/route.ts
- Stripe CLI test events are hitting the endpoint but signature check fails intermittently

## Next Steps
1. Test with Stripe CLI: stripe listen --forward-to localhost:3000/api/webhooks/stripe
2. Handle subscription.updated event
3. Update user plan in Neon DB on successful payment confirmation

## Blockers
- Webhook signature mismatch on local — possibly a raw body parsing issue with Next.js middleware

## Decisions Made
| Decision | Why | Date |
|----------|-----|------|
| Stripe over Paddle | Already in Vercel Marketplace, easier integration | 2026-03-18 |
| Webhooks over polling | Real-time + Stripe officially recommends it | 2026-03-19 |
| Clerk for auth | Handles social login + JWT out of the box | 2026-03-15 |

## Do Not Do
- Don't use Stripe.js for server-side operations
- Don't store raw card data — use Stripe Payment Intents only
- Don't skip idempotency keys on webhook handlers
