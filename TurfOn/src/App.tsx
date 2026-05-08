import { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './lib/supabase';
import { Session } from '@supabase/supabase-js';

import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import AdminTurfs from './pages/AdminTurfs';
import AdminUsers from './pages/AdminUsers';
import Layout from './components/Layout';
import { useOutletContext } from 'react-router-dom';

function DashboardWrapper({ session }: { session: Session }) {
  const { isAdmin } = useOutletContext<{ isAdmin: boolean }>();
  return isAdmin ? <AdminTurfs /> : <Dashboard session={session} />;
}

function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-black text-white">
        <div className="text-4xl font-bold animate-pulse">TURFON</div>
      </div>
    );
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/login" 
          element={!session ? <Login /> : <Navigate to="/" replace />} 
        />
        
        <Route 
          path="/register" 
          element={!session ? <Register /> : <Navigate to="/" replace />} 
        />
        
        <Route element={<Layout session={session} />}>
          <Route 
            path="/" 
            element={session ? <DashboardWrapper session={session} /> : <Navigate to="/login" replace />} 
          />
          <Route 
            path="/admin/users" 
            element={session ? <AdminUsers /> : <Navigate to="/login" replace />} 
          />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
