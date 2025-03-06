# Supabase Integration for Integrity Website

This document outlines how to set up Supabase for the Integrity website's user authentication and management system.

## Prerequisites

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new Supabase project

## Setup Steps

### 1. Database Setup

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `supabase_setup.sql` into the SQL editor
4. Run the SQL script to create the necessary tables and functions

### 2. Authentication Setup

1. In your Supabase dashboard, go to Authentication > Settings
2. Configure the following settings:
   - Under "Email Auth", make sure "Enable Email Signup" is enabled
   - Set the minimum password length (recommended: 8)
   - Configure any additional security settings you prefer

### 3. Add Your Supabase Credentials to the Website

Replace the placeholder values in `index.html` with your actual Supabase credentials:

```javascript
const supabaseUrl = 'YOUR_SUPABASE_URL'; // Replace with your Supabase URL
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your Supabase anon key
```

Your Supabase URL and anon key can be found in your Supabase project settings > API.

### 4. Testing the Integration

1. Deploy your website to Vercel
2. Test the signup and login functionality
3. Verify that user profiles are being created in the `user_profiles` table
4. Test the account management features

## Supabase Schema

The integration uses the following tables:

1. `user_profiles` - Stores additional user information and usage limits
   - `user_id` - References the Supabase auth.users table
   - `username` - User's display name
   - `questions_limit` - Daily usage limit for questions
   - `questions_used` - Number of questions used today
   - `last_question_time` - Timestamp of the last question asked

2. `usage_tracking` - Tracks user actions for analytics
   - `user_id` - References the Supabase auth.users table
   - `action_type` - Type of action performed (e.g., "download", "question")
   - `action_details` - JSON object with additional details about the action

## Security Considerations

1. Row Level Security (RLS) is enabled to ensure users can only access their own data
2. The database functions run with SECURITY DEFINER to allow creating user profiles
3. Make sure to keep your Supabase keys secure and never expose them in client-side code

## Scaling Considerations

1. The default daily question limit is set to 10, but this can be adjusted per user
2. Consider implementing a paid tier system by adding a `subscription_tier` column to the `user_profiles` table
3. For high-traffic applications, consider implementing rate limiting 