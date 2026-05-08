import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useOutletContext } from 'react-router-dom';
import { Mail, Calendar } from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface UserData {
  id: string;
  email: string;
  raw_user_meta_data: any;
  created_at: string;
}

export default function AdminUsers() {
  const { isAdmin } = useOutletContext<{ isAdmin: boolean }>();
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (isAdmin) {
      fetchUsers();
    }
  }, [isAdmin]);

  const fetchUsers = async () => {
    setLoading(true);
    // Using the secure function we defined in schema.sql
    const { data, error } = await supabase.rpc('get_all_users');
    if (data) {
      setUsers(data);
    }
    if (error) {
      console.error(error);
    }
    setLoading(false);
  };

  if (!isAdmin) {
    return <div className="text-red-500 font-bold uppercase p-8">Access Denied</div>;
  }

  if (loading) {
    return <div className="text-amber-500 font-bold uppercase tracking-widest animate-pulse">Loading Users...</div>;
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between border-b border-neutral-800 pb-4">
        <div>
          <h1 className="text-3xl font-black uppercase tracking-tight text-white">App Users</h1>
          <p className="text-neutral-400 text-sm mt-1 uppercase tracking-wider">Manage all registered users</p>
        </div>
        <div className="bg-amber-500 text-black px-4 py-2 font-black text-xl">
          {users.length} Total
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {users.map(user => (
          <div key={user.id} className="bg-neutral-900 border border-neutral-800 p-6 hover:border-neutral-700 transition-colors">
            <div className="font-bold text-lg text-white mb-1">
              {user.raw_user_meta_data?.full_name || user.email.split('@')[0]}
            </div>
            
            <div className="flex items-center gap-2 text-neutral-400 text-sm mb-4">
              <Mail size={14} />
              <span>{user.email}</span>
            </div>

            <div className="bg-black p-3 flex flex-col gap-2 border border-neutral-800">
              <div className="flex items-center justify-between">
                <span className="text-xs uppercase tracking-wider font-bold text-neutral-500">Phone</span>
                <span className="text-sm font-medium text-white">{user.raw_user_meta_data?.phone_number || 'N/A'}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-xs uppercase tracking-wider font-bold text-neutral-500">Joined</span>
                <span className="text-sm font-medium text-white flex items-center gap-1">
                  <Calendar size={12} className="text-amber-500" />
                  {format(parseISO(user.created_at), 'MMM do, yyyy')}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
