import { Navigate, Outlet, Link, useLocation } from 'react-router-dom';
import { Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { CalendarDays, LogOut, Users, Map } from 'lucide-react';
import { useEffect, useState } from 'react';

export default function Layout({ session }: { session: Session | null }) {
  const [isAdmin, setIsAdmin] = useState(false);
  const location = useLocation();

  useEffect(() => {
    if (session) {
      if (session.user.email === 'admin@turfon.com') {
        setIsAdmin(true);
      } else {
        supabase.from('admins').select('id').eq('id', session.user.id).single().then(({ data }) => {
          setIsAdmin(!!data);
        });
      }
    }
  }, [session]);

  if (!session) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans selection:bg-amber-500 selection:text-black">
      {/* Sidebar / Topbar */}
      <header className="border-b border-neutral-800 bg-black sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-20 items-center">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-amber-500 flex items-center justify-center rounded-none text-black font-bold">
                <CalendarDays size={24} />
              </div>
              <span className="text-2xl font-black tracking-tight text-white uppercase">
                Turf<span className="text-amber-500">On</span> Admin
              </span>
            </div>
            
            <nav className="flex items-center gap-6">
              {isAdmin && (
                <>
                  <Link to="/" className={`flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition-colors text-sm font-medium uppercase tracking-wider ${location.pathname === '/' ? 'text-amber-500' : 'text-neutral-400 hover:text-white'}`}>
                    <Map size={16} /> Turfs
                  </Link>
                  <Link to="/admin/users" className={`flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition-colors text-sm font-medium uppercase tracking-wider ${location.pathname === '/admin/users' ? 'text-amber-500' : 'text-neutral-400 hover:text-white'}`}>
                    <Users size={16} /> Users
                  </Link>
                </>
              )}
              <button
                onClick={() => supabase.auth.signOut()}
                className="flex items-center gap-2 px-4 py-2 hover:bg-neutral-800 transition-colors text-sm font-medium uppercase tracking-wider text-neutral-400 hover:text-white"
              >
                <LogOut size={16} />
                Sign Out
              </button>
            </nav>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet context={{ isAdmin }} />
      </main>
    </div>
  );
}
