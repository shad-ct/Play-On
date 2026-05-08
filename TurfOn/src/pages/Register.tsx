import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { ArrowRight, LogIn } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';

export default function Register() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    phone_number: '',
    location_map_link: '',
    price_per_hour: '',
    open_time: '',
    close_time: '',
    sports_supported: [] as string[],
  });

  const availableSports = ['Football', 'Cricket', 'Badminton'];

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSportToggle = (sport: string) => {
    setFormData(prev => ({
      ...prev,
      sports_supported: prev.sports_supported.includes(sport)
        ? prev.sports_supported.filter(s => s !== sport)
        : [...prev.sports_supported, sport]
    }));
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    // 1. Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: formData.email,
      password: formData.password,
    });

    if (authError) {
      if (authError.status === 429) {
        setError("Email rate limit exceeded. You've tried to register too many times recently. Please wait or disable Email Confirmations in your Supabase Dashboard.");
      } else {
        setError(authError.message);
      }
      setLoading(false);
      return;
    }

    if (authData.user) {
      // 2. Insert turf details
      const { error: insertError } = await supabase.from('turfs').insert([
        {
          id: authData.user.id,
          name: formData.name,
          email: formData.email,
          phone_number: formData.phone_number,
          location_map_link: formData.location_map_link,
          price_per_hour: formData.price_per_hour ? parseFloat(formData.price_per_hour) : null,
          open_time: formData.open_time,
          close_time: formData.close_time,
          sports_supported: formData.sports_supported,
          status: 'pending',
        },
      ]);

      if (insertError) {
        if (insertError.code === '23503') {
          setError('This email is already registered. Please log in or use a different email.');
        } else {
          setError(insertError.message);
        }
      } else {
        // Redirect to dashboard or waiting page
        navigate('/');
      }
    }

    setLoading(false);
  };

  return (
    <div className="min-h-screen bg-black flex flex-col justify-center py-12 sm:px-6 lg:px-8 font-sans selection:bg-amber-500 selection:text-black">
      <div className="sm:mx-auto sm:w-full sm:max-w-xl">
        <h2 className="mt-6 text-center text-4xl font-black tracking-tight text-white uppercase">
          Join <span className="text-amber-500">TurfOn</span>
        </h2>
        <p className="mt-2 text-center text-sm text-neutral-400 uppercase tracking-widest font-bold">
          Register Your Turf
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-xl">
        <div className="bg-neutral-900 py-8 px-4 border border-neutral-800 shadow sm:px-10">
          <form className="space-y-6" onSubmit={handleRegister}>
            {error && (
              <div className="bg-red-500/10 border border-red-500 text-red-500 p-3 text-sm font-medium">
                {error}
              </div>
            )}

            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Turf Name
                </label>
                <input
                  name="name" type="text" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="Greenfield Arena"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Email
                </label>
                <input
                  name="email" type="email" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="turf@example.com"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Password
                </label>
                <input
                  name="password" type="password" required minLength={6} onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="••••••••"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Phone Number
                </label>
                <input
                  name="phone_number" type="tel" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="+1 234 567 890"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Google Maps Link
                </label>
                <input
                  name="location_map_link" type="url" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="https://maps.google.com/..."
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Price / Hour (₹)
                </label>
                <input
                  name="price_per_hour" type="number" required min={0} step="0.01" onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                  placeholder="500"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Opening Time
                </label>
                <input
                  name="open_time" type="time" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                />
              </div>

              <div>
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300">
                  Closing Time
                </label>
                <input
                  name="close_time" type="time" required onChange={handleChange}
                  className="mt-2 block w-full appearance-none bg-black border border-neutral-800 px-3 py-3 text-white placeholder-neutral-500 focus:border-amber-500 focus:outline-none focus:ring-0 sm:text-sm transition-colors"
                />
              </div>

              <div className="sm:col-span-2">
                <label className="block text-sm font-bold uppercase tracking-wider text-neutral-300 mb-2">
                  Games Supported
                </label>
                <div className="flex flex-wrap gap-4">
                  {availableSports.map(sport => (
                    <label key={sport} className="flex items-center space-x-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={formData.sports_supported.includes(sport)}
                        onChange={() => handleSportToggle(sport)}
                        className="form-checkbox h-5 w-5 text-amber-500 bg-black border-neutral-800 rounded focus:ring-amber-500 focus:ring-offset-black"
                      />
                      <span className="text-white text-sm font-medium">{sport}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>

            <div className="pt-4 flex items-center justify-between">
              <Link to="/login" className="text-sm font-bold uppercase tracking-wider text-neutral-400 hover:text-amber-500 flex items-center gap-2 transition-colors">
                <LogIn size={16} /> Back to Login
              </Link>

              <button
                type="submit"
                disabled={loading}
                className="group relative flex justify-center bg-amber-500 py-3 px-8 text-sm font-bold uppercase tracking-widest text-black hover:bg-amber-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 focus:ring-offset-black disabled:opacity-50 transition-all"
              >
                {loading ? 'Submitting...' : 'Register'}
                {!loading && (
                  <span className="ml-2 flex items-center">
                    <ArrowRight className="h-5 w-5 text-black group-hover:translate-x-1 transition-transform" aria-hidden="true" />
                  </span>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
