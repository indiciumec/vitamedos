'use client';

import { useRouter } from 'next/navigation';
import { QRCodeSVG } from 'qrcode.react';

export function PrintButton() {
  const router = useRouter();
  return (
    <div className="no-print mb-4 flex gap-3">
      <button
        onClick={() => window.print()}
        className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
      >
        Imprimir
      </button>
      <button
        onClick={() => router.back()}
        className="rounded-md border border-vitamed-200 px-5 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50"
      >
        Volver
      </button>
    </div>
  );
}

export function QR({ value, size = 64 }: { value: string; size?: number }) {
  return <QRCodeSVG value={value} size={size} />;
}
