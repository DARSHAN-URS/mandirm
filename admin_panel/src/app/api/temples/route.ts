import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('temples')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { name, deity, city, state, address, description, image_url, live_darshan_url, darshan_timings, aarti_timings, is_featured } = body;

    // Strict validation of required fields
    if (!name?.trim()) return NextResponse.json({ error: 'Temple name is required' }, { status: 400 });
    if (!deity?.trim()) return NextResponse.json({ error: 'Deity name is required' }, { status: 400 });
    if (!city?.trim()) return NextResponse.json({ error: 'City is required' }, { status: 400 });
    if (!state?.trim()) return NextResponse.json({ error: 'State is required' }, { status: 400 });
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `temple_${Date.now()}`;

    const newTemple = {
      id,
      name: name.trim(),
      deity: deity.trim(),
      city: city.trim(),
      state: state.trim(),
      address: address?.trim() || `${city.trim()}, ${state.trim()}`,
      description: description.trim(),
      image_url: image_url.trim(),
      live_darshan_url: live_darshan_url?.trim() || null,
      darshan_timings: darshan_timings?.trim() || '05:00 AM - 10:00 PM',
      aarti_timings: aarti_timings?.trim() || 'Pratah: 06:00 AM | Sandhya: 07:00 PM',
      rating: 4.95,
      reviews_count: 108,
      is_featured: is_featured ?? true,
    };

    const { data, error } = await supabaseServer
      .from('temples')
      .upsert(newTemple)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message, detail: error }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create temple' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Temple ID is required' }, { status: 400 });

    const { data, error } = await supabaseServer
      .from('temples')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update temple' }, { status: 500 });
  }
}

export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const id = searchParams.get('id');

    if (!id) return NextResponse.json({ error: 'Temple ID is required' }, { status: 400 });

    const { error } = await supabaseServer.from('temples').delete().eq('id', id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Temple deleted successfully' });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to delete temple' }, { status: 500 });
  }
}
