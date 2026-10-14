import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('chadhawa_offerings')
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
    const { title, temple_name, temple_id, category, price, description, image_url } = body;

    // Strict validation of required fields
    if (!title?.trim()) return NextResponse.json({ error: 'Chadhawa title is required' }, { status: 400 });
    if (!temple_name?.trim()) return NextResponse.json({ error: 'Temple name is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid price (Dakshina) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `chadhawa_${Date.now()}`;

    const newOffering = {
      id,
      title: title.trim(),
      temple_name: temple_name.trim(),
      temple_id: temple_id?.trim() || null,
      category: category?.trim() || 'Divine Offering',
      price: Number(price),
      description: description.trim(),
      image_url: image_url.trim(),
    };

    const { data, error } = await supabaseServer
      .from('chadhawa_offerings')
      .upsert(newOffering)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message, detail: error }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create chadhawa offering' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Offering ID is required' }, { status: 400 });

    if (updates.price !== undefined) {
      updates.price = Number(updates.price);
    }

    const { data, error } = await supabaseServer
      .from('chadhawa_offerings')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update chadhawa offering' }, { status: 500 });
  }
}

export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const id = searchParams.get('id');

    if (!id) return NextResponse.json({ error: 'Offering ID is required' }, { status: 400 });

    const { error } = await supabaseServer.from('chadhawa_offerings').delete().eq('id', id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Offering deleted successfully' });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to delete chadhawa offering' }, { status: 500 });
  }
}
