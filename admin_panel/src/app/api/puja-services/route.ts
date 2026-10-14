import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('puja_services')
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
    const { title, deity, category, temple_name, temple_id, price, vip_price, duration_minutes, description, benefits, image_url, is_popular } = body;

    // Required fields validation
    if (!title?.trim()) return NextResponse.json({ error: 'Puja title is required' }, { status: 400 });
    if (!temple_name?.trim()) return NextResponse.json({ error: 'Temple name is required' }, { status: 400 });
    if (!deity?.trim()) return NextResponse.json({ error: 'Deity is required' }, { status: 400 });
    if (!category?.trim()) return NextResponse.json({ error: 'Category is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid puja dakshina / price (₹) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Puja description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Puja image URL is required' }, { status: 400 });

    const id = body.id || `puja_${Date.now()}`;

    const newPuja = {
      id,
      title: title.trim(),
      temple_name: temple_name.trim(),
      temple_id: temple_id?.trim() || null,
      deity: deity.trim(),
      category: category.trim(),
      price: Number(price),
      vip_price: vip_price ? Number(vip_price) : Number(price) * 2,
      duration_minutes: duration_minutes ? Number(duration_minutes) : 45,
      description: description.trim(),
      benefits: benefits?.trim() || 'Bestows peace, prosperity, and divine protection upon devotee family.',
      image_url: image_url.trim(),
      is_popular: is_popular ?? false,
    };

    const { data, error } = await supabaseServer
      .from('puja_services')
      .upsert(newPuja)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message, detail: error }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create puja service' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Puja service ID is required' }, { status: 400 });

    if (updates.price !== undefined) updates.price = Number(updates.price);
    if (updates.vip_price !== undefined) updates.vip_price = Number(updates.vip_price);
    if (updates.duration_minutes !== undefined) updates.duration_minutes = Number(updates.duration_minutes);

    const { data, error } = await supabaseServer
      .from('puja_services')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update puja service' }, { status: 500 });
  }
}

export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const id = searchParams.get('id');

    if (!id) return NextResponse.json({ error: 'Puja ID is required' }, { status: 400 });

    const { error } = await supabaseServer.from('puja_services').delete().eq('id', id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Puja service deleted successfully' });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to delete puja service' }, { status: 500 });
  }
}
