import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

function extractPujaMetadata(p: any) {
  if (!p || !p.description) return p;
  let desc = p.description || '';
  const match = desc.match(/<!--\s*METADATA:\s*([\s\S]*?)\s*-->/);
  if (match && match[1]) {
    try {
      const meta = JSON.parse(match[1]);
      desc = desc.replace(match[0], '').trim();
      return {
        ...meta,
        ...p,
        description: desc,
        ...(meta.title_hi ? { title_hi: meta.title_hi } : {}),
        ...(meta.temple_name_hi ? { temple_name_hi: meta.temple_name_hi } : {}),
        ...(meta.description_hi ? { description_hi: meta.description_hi } : {}),
        ...(meta.benefits_hi ? { benefits_hi: meta.benefits_hi } : {}),
        ...(meta.samagri_included_hi ? { samagri_included_hi: meta.samagri_included_hi } : {}),
        ...(meta.faqs ? { faqs: meta.faqs } : {}),
      };
    } catch (_) {}
  }
  return p;
}

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('puja_services')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    const enriched = (data || []).map(extractPujaMetadata);
    return NextResponse.json({ success: true, data: enriched });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const {
      title,
      title_hi,
      deity,
      category,
      temple_name,
      temple_name_hi,
      price,
      vip_price,
      duration_minutes,
      description,
      description_hi,
      benefits,
      benefits_hi,
      samagri_included,
      samagri_included_hi,
      image_url,
      is_popular,
      faqs,
    } = body;

    if (!title?.trim()) return NextResponse.json({ error: 'Puja title is required' }, { status: 400 });
    if (!temple_name?.trim()) return NextResponse.json({ error: 'Temple destination is required' }, { status: 400 });
    if (!category?.trim()) return NextResponse.json({ error: 'Category is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid price (₹) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `puja_${Date.now()}`;

    const metadata = {
      title_hi: title_hi?.trim() || undefined,
      temple_name_hi: temple_name_hi?.trim() || undefined,
      description_hi: description_hi?.trim() || undefined,
      benefits_hi: benefits_hi?.trim() || undefined,
      samagri_included_hi: samagri_included_hi?.trim() || undefined,
      faqs: Array.isArray(faqs) ? faqs : [],
    };

    const cleanDesc = (description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
    const finalDescription = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
      ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
      : cleanDesc;

    const basePayload = {
      id,
      title: title.trim(),
      deity: deity?.trim() || 'Lord Shiva',
      category: category.trim(),
      temple_name: temple_name.trim(),
      price: Number(price),
      vip_price: vip_price ? Number(vip_price) : Number(price) * 1.5,
      duration_minutes: duration_minutes ? Number(duration_minutes) : 60,
      description: finalDescription,
      benefits: benefits?.trim() || null,
      samagri_included: samagri_included?.trim() || 'Sacred Samagri Included',
      image_url: image_url.trim(),
      is_popular: is_popular ?? true,
    };

    const fullPayload = {
      ...basePayload,
      ...(title_hi ? { title_hi: title_hi.trim() } : {}),
      ...(temple_name_hi ? { temple_name_hi: temple_name_hi.trim() } : {}),
      ...(description_hi ? { description_hi: description_hi.trim() } : {}),
      ...(benefits_hi ? { benefits_hi: benefits_hi.trim() } : {}),
      ...(samagri_included_hi ? { samagri_included_hi: samagri_included_hi.trim() } : {}),
      ...(Array.isArray(faqs) ? { faqs } : {}),
    };

    let result = await supabaseServer.from('puja_services').upsert(fullPayload).select().single();

    if (result.error) {
      result = await supabaseServer.from('puja_services').upsert(basePayload).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractPujaMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create puja' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Puja ID is required' }, { status: 400 });

    if (updates.price !== undefined) updates.price = Number(updates.price);
    if (updates.vip_price !== undefined) updates.vip_price = Number(updates.vip_price);
    if (updates.duration_minutes !== undefined) updates.duration_minutes = Number(updates.duration_minutes);

    const metadata = {
      title_hi: updates.title_hi?.trim() || undefined,
      temple_name_hi: updates.temple_name_hi?.trim() || undefined,
      description_hi: updates.description_hi?.trim() || undefined,
      benefits_hi: updates.benefits_hi?.trim() || undefined,
      samagri_included_hi: updates.samagri_included_hi?.trim() || undefined,
      faqs: Array.isArray(updates.faqs) ? updates.faqs : [],
    };

    if (updates.description !== undefined) {
      const cleanDesc = (updates.description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
      updates.description = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
        ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
        : cleanDesc;
    }

    let result = await supabaseServer.from('puja_services').update(updates).eq('id', id).select().single();

    if (result.error) {
      const {
        title_hi,
        temple_name_hi,
        description_hi,
        benefits_hi,
        samagri_included_hi,
        faqs,
        ...baseUpdates
      } = updates;
      result = await supabaseServer.from('puja_services').update(baseUpdates).eq('id', id).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractPujaMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update puja' }, { status: 500 });
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

    return NextResponse.json({ success: true, message: 'Puja deleted successfully' });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to delete puja' }, { status: 500 });
  }
}
