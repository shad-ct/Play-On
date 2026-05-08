import { useState, useEffect } from 'react';
import { Session } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { format, startOfWeek, addDays, isSameDay, parseISO } from 'date-fns';
import { Check, X, Clock, User, Phone, MapPin } from 'lucide-react';

interface Booking {
  id: string;
  turf_id: string;
  player_name: string;
  player_phone: string;
  booking_date: string;
  start_time: string;
  end_time: string;
  status: 'pending' | 'approved' | 'rejected';
}

interface Turf {
  id: string;
  name: string;
  location: string;
}

export default function Dashboard({ session }: { session: Session }) {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [turf, setTurf] = useState<Turf | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentWeekStart, setCurrentWeekStart] = useState(startOfWeek(new Date(), { weekStartsOn: 1 }));

  useEffect(() => {
    fetchData();
  }, [session.user.id]);

  const fetchData = async () => {
    setLoading(true);
    
    // Fetch turf details
    const { data: turfData } = await supabase
      .from('turfs')
      .select('*')
      .eq('id', session.user.id)
      .single();
      
    if (turfData) setTurf(turfData);

    // Fetch bookings
    const { data: bookingsData } = await supabase
      .from('bookings')
      .select('*')
      .eq('turf_id', session.user.id)
      .order('booking_date', { ascending: true })
      .order('start_time', { ascending: true });

    if (bookingsData) {
      setBookings(bookingsData);
    }
    
    setLoading(false);
  };

  const updateBookingStatus = async (id: string, status: 'approved' | 'rejected') => {
    const { error } = await supabase
      .from('bookings')
      .update({ status })
      .eq('id', id);

    if (!error) {
      setBookings(bookings.map(b => b.id === id ? { ...b, status } : b));
    }
  };

  const weekDays = Array.from({ length: 7 }).map((_, i) => addDays(currentWeekStart, i));

  if (loading) {
    return <div className="text-amber-500 font-bold uppercase tracking-widest animate-pulse">Loading Dashboard...</div>;
  }

  const pendingRequests = bookings.filter(b => b.status === 'pending');

  return (
    <div className="space-y-12">
      {/* Turf Info Header */}
      {turf && (
        <div className="bg-black border border-neutral-800 p-8 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <h1 className="text-4xl font-black uppercase tracking-tight text-white">{turf.name}</h1>
            <div className="flex items-center gap-2 mt-2 text-neutral-400 font-medium">
              <MapPin size={18} className="text-amber-500" />
              <span className="uppercase tracking-wider text-sm">{turf.location}</span>
            </div>
          </div>
          <div className="bg-neutral-900 px-6 py-4 border-l-4 border-amber-500">
            <div className="text-sm uppercase tracking-widest text-neutral-500 font-bold">Total Bookings</div>
            <div className="text-3xl font-black text-white">{bookings.length}</div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Col: Pending Requests */}
        <div className="lg:col-span-1 space-y-6">
          <div className="flex items-center justify-between border-b border-neutral-800 pb-4">
            <h2 className="text-xl font-black uppercase tracking-wider text-white">Pending Requests</h2>
            <span className="bg-amber-500 text-black px-3 py-1 text-xs font-bold rounded-full">
              {pendingRequests.length}
            </span>
          </div>

          {pendingRequests.length === 0 ? (
            <div className="bg-neutral-900 border border-neutral-800 p-8 text-center text-neutral-500 uppercase font-bold tracking-wider text-sm">
              No pending requests
            </div>
          ) : (
            <div className="space-y-4">
              {pendingRequests.map(request => (
                <div key={request.id} className="bg-neutral-900 border border-neutral-800 p-5 group hover:border-neutral-600 transition-colors">
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <div className="font-bold text-lg text-white capitalize">{request.player_name}</div>
                      <div className="flex items-center gap-1 text-neutral-400 text-sm mt-1">
                        <Phone size={14} />
                        {request.player_phone}
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-black p-3 mb-4 flex items-center gap-3 border border-neutral-800">
                    <Clock size={16} className="text-amber-500" />
                    <div className="text-sm font-medium text-neutral-300">
                      <div>{format(parseISO(request.booking_date), 'MMM do, yyyy')}</div>
                      <div className="text-white font-bold">{request.start_time.substring(0, 5)} - {request.end_time.substring(0, 5)}</div>
                    </div>
                  </div>

                  <div className="flex gap-3">
                    <button
                      onClick={() => updateBookingStatus(request.id, 'approved')}
                      className="flex-1 bg-amber-500 text-black py-2 font-bold uppercase text-xs tracking-wider flex items-center justify-center gap-2 hover:bg-amber-400 transition-colors"
                    >
                      <Check size={16} /> Approve
                    </button>
                    <button
                      onClick={() => updateBookingStatus(request.id, 'rejected')}
                      className="flex-1 bg-neutral-800 text-white py-2 font-bold uppercase text-xs tracking-wider flex items-center justify-center gap-2 hover:bg-neutral-700 transition-colors"
                    >
                      <X size={16} /> Reject
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Right Col: Calendar View */}
        <div className="lg:col-span-2 space-y-6">
          <div className="flex items-center justify-between border-b border-neutral-800 pb-4">
            <h2 className="text-xl font-black uppercase tracking-wider text-white">Schedule Allocation</h2>
            <div className="flex gap-2">
              <button 
                onClick={() => setCurrentWeekStart(addDays(currentWeekStart, -7))}
                className="px-4 py-2 bg-neutral-900 border border-neutral-800 hover:bg-neutral-800 text-sm font-bold uppercase tracking-wider transition-colors"
              >
                Prev
              </button>
              <button 
                onClick={() => setCurrentWeekStart(addDays(currentWeekStart, 7))}
                className="px-4 py-2 bg-neutral-900 border border-neutral-800 hover:bg-neutral-800 text-sm font-bold uppercase tracking-wider transition-colors"
              >
                Next
              </button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-7 gap-4">
            {weekDays.map(day => {
              const dayBookings = bookings.filter(
                b => isSameDay(parseISO(b.booking_date), day) && b.status === 'approved'
              );

              const isToday = isSameDay(day, new Date());

              return (
                <div key={day.toISOString()} className={`flex flex-col border ${isToday ? 'border-amber-500' : 'border-neutral-800'} bg-neutral-900 min-h-[300px]`}>
                  <div className={`p-3 text-center border-b ${isToday ? 'bg-amber-500 text-black border-amber-500' : 'bg-black border-neutral-800'}`}>
                    <div className="text-xs uppercase font-bold tracking-widest">{format(day, 'EEE')}</div>
                    <div className="text-2xl font-black mt-1">{format(day, 'd')}</div>
                  </div>
                  
                  <div className="p-2 space-y-2 flex-1 overflow-y-auto">
                    {dayBookings.length === 0 ? (
                      <div className="text-neutral-600 text-xs text-center mt-4 font-medium uppercase">No slots</div>
                    ) : (
                      dayBookings.map(booking => (
                        <div key={booking.id} className="bg-neutral-800 p-2 border-l-2 border-amber-500 hover:bg-neutral-700 transition-colors cursor-pointer group">
                          <div className="text-xs font-bold text-white group-hover:text-amber-500 transition-colors">
                            {booking.start_time.substring(0, 5)} - {booking.end_time.substring(0, 5)}
                          </div>
                          <div className="text-[10px] text-neutral-400 mt-1 uppercase tracking-wider truncate flex items-center gap-1">
                            <User size={10} />
                            {booking.player_name}
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
