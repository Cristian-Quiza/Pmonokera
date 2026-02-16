import type { Metadata } from "next";
import "../src/app/globals.css";

export const metadata: Metadata = {
  title: "Sistema de Órdenes",
  description: "Gestiona tus órdenes de forma eficiente",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" suppressHydrationWarning>
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
