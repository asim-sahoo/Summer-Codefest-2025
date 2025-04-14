import { Link } from "react-router-dom";

interface AuthLayoutProps {
  children: React.ReactNode;
  title: string;
  description: string;
  footer: React.ReactNode;
}

export function AuthLayout({ children, title, description, footer }: AuthLayoutProps) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <Link to="/" className="inline-flex items-center gap-2 mb-8">
            <div className="rounded-md bg-gradient-to-r from-blue-600 to-purple-600 p-1.5">
              <span className="text-xl font-bold text-white">W</span>
            </div>
            <span className="text-xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">WellSta</span>
          </Link>
          
          <h1 className="text-2xl font-bold tracking-tight mb-2">{title}</h1>
          <p className="text-muted-foreground">{description}</p>
        </div>
        
        <div className="bg-card p-6 rounded-lg border shadow-sm animate-fade-in">
          {children}
        </div>
        
        <div className="mt-6 text-center text-sm">
          {footer}
        </div>
      </div>
    </div>
  );
}
