// @ts-check
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    proxyTimeout: 90_000,
  },
  reactStrictMode: false,
  transpilePackages: ['crypto-hash'],
  images: {
    remotePatterns: [
      {
        protocol: 'http',
        hostname: '**',
      },
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
  },
  async redirects() {
    return [
      {
        source: '/api/uploads/:path*',
        destination:
          process.env.STORAGE_PROVIDER === 'local' ? '/uploads/:path*' : '/404',
        permanent: true,
      },
    ];
  },
  async rewrites() {
    return [
      {
        source: '/uploads/:path*',
        destination:
          process.env.STORAGE_PROVIDER === 'local'
            ? '/api/uploads/:path*'
            : '/404',
      },
      // Proxy API requests directly to backend (bypass Caddy)
      {
        source: '/api/:path*',
        destination: 'http://localhost:3000/api/:path*',
      },
      // Proxy auth requests directly to backend (bypass Caddy)
      {
        source: '/auth/:path*',
        destination: 'http://localhost:3000/auth/:path*',
      },
    ];
  },
};
export default nextConfig;
