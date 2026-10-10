/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['images.unsplash.com', 'your-project.supabase.co'],
    unoptimized: true,
  },
};

module.exports = nextConfig;
