/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Hay un package-lock.json suelto en el home del usuario; fijamos la raíz.
  turbopack: { root: import.meta.dirname },
};

export default nextConfig;
