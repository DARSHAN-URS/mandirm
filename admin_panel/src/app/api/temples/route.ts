import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

function extractTempleMetadata(t: any) {
  if (!t || !t.description) return t;
  let desc = t.description || '';
  const match = desc.match(/<!--\s*METADATA:\s*([\s\S]*?)\s*-->/);
  if (match && match[1]) {
    try {
      const meta = JSON.parse(match[1]);
      desc = desc.replace(match[0], '').trim();
      return {
        ...meta,
        ...t,
        description: desc,
        ...(meta.name_hi ? { name_hi: meta.name_hi } : {}),
        ...(meta.description_hi ? { description_hi: meta.description_hi } : {}),
        ...(meta.deity_hi ? { deity_hi: meta.deity_hi } : {}),
        ...(meta.city_hi ? { city_hi: meta.city_hi } : {}),
        ...(meta.state_hi ? { state_hi: meta.state_hi } : {}),
        ...(meta.history_hi ? { history_hi: meta.history_hi } : {}),
        ...(meta.significance ? { significance: meta.significance } : {}),
        ...(meta.significance_hi ? { significance_hi: meta.significance_hi } : {}),
        ...(meta.faqs ? { faqs: meta.faqs } : {}),
      };
    } catch (_) {}
  }
  return t;
}

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('temples')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    const enriched = (data || []).map(extractTempleMetadata);
    return NextResponse.json({ success: true, data: enriched });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const {
      name,
      name_hi,
      deity,
      deity_hi,
      city,
      city_hi,
      state,
      state_hi,
      address,
      description,
      description_hi,
      history,
      history_hi,
      significance,
      significance_hi,
      image_url,
      live_darshan_url,
      darshan_timings,
      aarti_timings,
      is_featured,
      faqs,
    } = body;

    if (!name?.trim()) return NextResponse.json({ error: 'Temple name is required' }, { status: 400 });
    if (!deity?.trim()) return NextResponse.json({ error: 'Deity name is required' }, { status: 400 });
    if (!city?.trim()) return NextResponse.json({ error: 'City is required' }, { status: 400 });
    if (!state?.trim()) return NextResponse.json({ error: 'State is required' }, { status: 400 });
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `temple_${Date.now()}`;

    const metadata = {
      name_hi: name_hi?.trim() || undefined,
      description_hi: description_hi?.trim() || undefined,
      deity_hi: deity_hi?.trim() || undefined,
      city_hi: city_hi?.trim() || undefined,
      state_hi: state_hi?.trim() || undefined,
      history_hi: history_hi?.trim() || undefined,
      significance: significance?.trim() || undefined,
      significance_hi: significance_hi?.trim() || undefined,
      faqs: Array.isArray(faqs) ? faqs : [],
    };

    const cleanDesc = (description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
    const finalDescription = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
      ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
      : cleanDesc;

    const basePayload = {
      id,
      name: name.trim(),
      deity: deity.trim(),
      city: city.trim(),
      state: state.trim(),
      address: address?.trim() || `${city.trim()}, ${state.trim()}`,
      description: finalDescription,
      history: history?.trim() || null,
      image_url: image_url.trim(),
      live_darshan_url: live_darshan_url?.trim() || null,
      darshan_timings: darshan_timings?.trim() || '05:00 AM - 10:00 PM',
      aarti_timings: aarti_timings?.trim() || 'Pratah: 06:00 AM | Sandhya: 07:00 PM',
      rating: 4.95,
      reviews_count: 108,
      is_featured: is_featured ?? true,
    };

    const fullPayload = {
      ...basePayload,
      ...(name_hi ? { name_hi: name_hi.trim() } : {}),
      ...(description_hi ? { description_hi: description_hi.trim() } : {}),
      ...(deity_hi ? { deity_hi: deity_hi.trim() } : {}),
      ...(city_hi ? { city_hi: city_hi.trim() } : {}),
      ...(state_hi ? { state_hi: state_hi.trim() } : {}),
      ...(history_hi ? { history_hi: history_hi.trim() } : {}),
      ...(significance ? { significance: significance.trim() } : {}),
      ...(significance_hi ? { significance_hi: significance_hi.trim() } : {}),
      ...(Array.isArray(faqs) ? { faqs } : {}),
    };

    let result = await supabaseServer.from('temples').upsert(fullPayload).select().single();

    if (result.error) {
      result = await supabaseServer.from('temples').upsert(basePayload).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractTempleMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create temple' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Temple ID is required' }, { status: 400 });

    const metadata = {
      name_hi: updates.name_hi?.trim() || undefined,
      description_hi: updates.description_hi?.trim() || undefined,
      deity_hi: updates.deity_hi?.trim() || undefined,
      city_hi: updates.city_hi?.trim() || undefined,
      state_hi: updates.state_hi?.trim() || undefined,
      history_hi: updates.history_hi?.trim() || undefined,
      significance: updates.significance?.trim() || undefined,
      significance_hi: updates.significance_hi?.trim() || undefined,
      faqs: Array.isArray(updates.faqs) ? updates.faqs : [],
    };

    if (updates.description !== undefined) {
      const cleanDesc = (updates.description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
      updates.description = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
        ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
        : cleanDesc;
    }

    let result = await supabaseServer.from('temples').update(updates).eq('id', id).select().single();

    if (result.error) {
      const {
        name_hi,
        description_hi,
        deity_hi,
        city_hi,
        state_hi,
        history_hi,
        significance,
        significance_hi,
        faqs,
        ...baseUpdates
      } = updates;
      result = await supabaseServer.from('temples').update(baseUpdates).eq('id', id).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractTempleMetadata(result.data) });
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
