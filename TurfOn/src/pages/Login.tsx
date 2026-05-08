import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const { data: authData, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError(error.message);
      setLoading(false);
      return;
    }

    if (authData.user) {
      // Check if user is an admin or turf owner
      const { data: adminData } = await supabase.from('admins').select('id').eq('id', authData.user.id).single();
      const { data: turfData } = await supabase.from('turfs').select('id').eq('id', authData.user.id).single();
      
      const isSuperAdmin = authData.user.email === 'admin@turfon.com';
      
      if (!adminData && !turfData && !isSuperAdmin) {
        await supabase.auth.signOut();
        setError('Access denied. Only Turf Administrators can access this portal.');
      }
    }
    
    setLoading(false);
  };

  return (
    <div className="min-h-screen bg-black flex flex-col justify-center py-12 sm:px-6 lg:px-8 font-sans selection:bg-amber-500 selection:text-black">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="mt-6 text-center text-4xl font-black tracking-tight text-white uppercase">
          Turf<span className="text-amber-500">On</span>
        </h2>
        <p className="mt-2 text-center text-sm text-neutral-400 uppercase tracking-widest font-bold">
          Admin Portal
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-neutral-900 py-8 px-4 border border-neutral-800 shadow sm:px-10">
          <form className="space-y-6" onSubmit={handleLogin}>
            {error && (
              <div className="bg-red-500/10 border border-red-500 text-red-500 p-3 text-sm font-medium">
                {error}
              </div>
            )}
            
            <div>
              <label htmlFor="email" className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                Email address
              </label>
              <div className="mt-2">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="admin@turfon.com"
                />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                Password
              </label>
              <div className="mt-2">
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="group relative flex w-full justify-center bg-amber-500 py-3 px-4 text-sm font-bold uppercase tracking-widest text-black hover:bg-amber-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 focus:ring-offset-black disabled:opacity-50 transition-all"
              >
                {loading ? 'Authenticating...' : 'Sign In'}
                {!loading && (
                  <span className="absolute inset-y-0 right-0 flex items-center pr-3">
                    <ArrowRight className="h-5 w-5 text-black group-hover:translate-x-1 transition-transform" aria-hidden="true" />
                  </span>
                )}
              </button>
            </div>
            
            <div className="mt-6 text-center text-sm font-bold uppercase tracking-wider text-neutral-400">
              Don't have an account?{' '}
              <Link to="/register" className="text-amber-500 hover:text-amber-400 transition-colors">
                Register Turf
              </Link>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
