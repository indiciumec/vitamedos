import type { Metadata } from 'next';
import { Quicksand } from 'next/font/google';
import './globals.css';

const quicksand = Quicksand({
  subsets: ['latin'],
  variable: '--font-quicksand',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Vitamed OS',
  description: 'Sistema de gestión clínica — Consultorio Vitamed',
  icons: { icon: '/logo.svg' },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" className={quicksand.variable}>
      <body className="min-h-screen bg-vitamed-50 text-vitamed-950 antialiased">{children}</body>
    </html>
  );
}
