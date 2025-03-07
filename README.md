# Integrity Software Website

This repository contains the website for Integrity Software, to be deployed on Vercel with the domain integritysofware.download.

## User Authentication with Supabase

This website uses Supabase for user authentication and management. For detailed setup instructions, see [SUPABASE.md](SUPABASE.md).

### Features
- User signup and login
- Account management
- Usage tracking for questions/interactions
- Daily usage limits

Before deploying, make sure to:
1. Set up your Supabase project
2. Run the database setup script in `supabase_setup.sql`
3. Replace the Supabase credentials in `index.html`

## Deployment Instructions

### Deploying to Vercel

1. Create a Vercel account if you don't have one already at [vercel.com](https://vercel.com)
2. Install the Vercel CLI:
   ```
   npm install -g vercel
   ```
3. Login to Vercel:
   ```
   vercel login
   ```
4. Deploy your website:
   ```
   vercel
   ```
5. For production deployment:
   ```
   vercel --prod
   ```

### Connecting Your Custom Domain

1. Go to your Vercel dashboard
2. Select your project
3. Go to "Settings" > "Domains"
4. Add your domain: `integritysofware.download`
5. Follow Vercel's instructions to configure your DNS settings

## Local Development

To test the website locally, you can use any local server such as:

```
npx serve
```

Or if you have Python installed:

```
# Python 3.x
python -m http.server

# Python 2.x
python -m SimpleHTTPServer
```

## Project Structure

- `index.html` - Main website page
- `public/downloads/` - Contains downloadable software packages
- `vercel.json` - Configuration file for Vercel deployment

## Important Notes for Deployment

The downloadable files must be placed in the `public/downloads/` directory for Vercel to serve them correctly. This is because Vercel serves static assets from the `public` directory.

If you're getting 404 errors when attempting to download files, make sure:
1. All files exist in the `public/downloads/` directory
2. The paths in the HTML file start with `/downloads/` (with a leading slash)
3. The Vercel configuration correctly routes `/downloads/` requests 