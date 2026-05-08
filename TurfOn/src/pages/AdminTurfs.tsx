import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { MapPin, Phone, Clock, DollarSign, ExternalLink, Check, X } from 'lucide-react';

interface Turf {
  id: string;
  name: string;
  email: string;
  phone_number: string;
  location_map_link: string;
  price_per_hour: number;
  open_time: string;
  close_time: string;
  status: 'pending' | 'approved' | 'rejected';
}

export default function AdminTurfs() {
  const [turfs, setTurfs] = useState<Turf[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTurfs();
  }, []);

  const fetchTurfs = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from('turfs')
      .select('*')
      .order('created_at', { ascending: false });

    if (data) {
      setTurfs(data);
    }
    if (error) {
      console.error(error);
    }
    setLoading(false);
  };

  const updateStatus = async (id: string, status: 'approved' | 'rejected') => {
    const { error } = await supabase
      .from('turfs')
      .update({ status })
      .eq('id', id);

    if (!error) {
      setTurfs(turfs.map(t => t.id === id ? { ...t, status } : t));
    }
  };

  if (loading) {
    return <div className="text-amber-500 font-bold uppercase tracking-widest animate-pulse">Loading Turfs...</div>;
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between border-b border-neutral-800 pb-4">
        <div>
          <h1 className="text-3xl font-black uppercase tracking-tight text-white">Manage Turfs</h1>
          <p className="text-neutral-400 text-sm mt-1 uppercase tracking-wider">Approve and monitor registered turfs</p>
        </div>
        <div className="bg-amber-500 text-black px-4 py-2 font-black text-xl">
          {turfs.length} Total
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
        {turfs.map(turf => (
          <div key={turf.id} className="bg-neutral-900 border border-neutral-800 flex flex-col group hover:border-neutral-600 transition-colors">
            <div className="p-6 flex-1 space-y-4">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-2xl font-black text-white uppercase">{turf.name}</h3>
                  <div className="flex items-center gap-2 text-neutral-400 text-sm mt-1">
                    <Phone size={14} />
                    <span>{turf.phone_number}</span>
                    <span className="text-neutral-600">|</span>
                    <span className="truncate">{turf.email}</span>
                  </div>
                </div>
                <div>
                  <span className={`px-2 py-1 text-xs font-bold uppercase tracking-wider ${
                    turf.status === 'approved' ? 'bg-green-500/10 text-green-500 border border-green-500/20' : 
                    turf.status === 'rejected' ? 'bg-red-500/10 text-red-500 border border-red-500/20' : 
                    'bg-amber-500/10 text-amber-500 border border-amber-500/20'
                  }`}>
                    {turf.status || 'pending'}
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="bg-black p-3 border border-neutral-800">
                  <div className="flex items-center gap-2 text-neutral-500 mb-1">
                    <Clock size={14} className="text-amber-500" />
                    <span className="text-xs uppercase font-bold tracking-wider">Timings</span>
                  </div>
                  <div className="text-sm font-medium text-white">
                    {turf.open_time?.substring(0, 5) || '--'} to {turf.close_time?.substring(0, 5) || '--'}
                  </div>
                </div>

                <div className="bg-black p-3 border border-neutral-800">
                  <div className="flex items-center gap-2 text-neutral-500 mb-1">
                    <DollarSign size={14} className="text-amber-500" />
                    <span className="text-xs uppercase font-bold tracking-wider">Pricing</span>
                  </div>
                  <div className="text-sm font-medium text-white">
                    ₹{turf.price_per_hour}/hr
                  </div>
                </div>
              </div>

              <a 
                href={turf.location_map_link} 
                target="_blank" 
                rel="noreferrer"
                className="flex items-center gap-2 text-sm text-amber-500 hover:text-amber-400 transition-colors w-max font-medium"
              >
                <MapPin size={16} />
                View Location on Maps
                <ExternalLink size={14} />
              </a>
            </div>

            <div className="grid grid-cols-2 border-t border-neutral-800">
              <button
                onClick={() => updateStatus(turf.id, 'approved')}
                disabled={turf.status === 'approved'}
                className="py-3 flex items-center justify-center gap-2 text-sm font-bold uppercase tracking-wider text-green-500 hover:bg-green-500/10 disabled:opacity-30 disabled:hover:bg-transparent transition-colors border-r border-neutral-800"
              >
                <Check size={16} /> Approve
              </button>
              <button
                onClick={() => updateStatus(turf.id, 'rejected')}
                disabled={turf.status === 'rejected'}
                className="py-3 flex items-center justify-center gap-2 text-sm font-bold uppercase tracking-wider text-red-500 hover:bg-red-500/10 disabled:opacity-30 disabled:hover:bg-transparent transition-colors"
              >
                <X size={16} /> Reject
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
