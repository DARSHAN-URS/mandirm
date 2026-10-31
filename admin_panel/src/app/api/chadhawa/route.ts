import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

function extractChadhawaMetadata(c: any) {
  if (!c || !c.description) return c;
  let desc = c.description || '';
  const match = desc.match(/<!--\s*METADATA:\s*([\s\S]*?)\s*-->/);
  if (match && match[1]) {
    try {
      const meta = JSON.parse(match[1]);
      desc = desc.replace(match[0], '').trim();
      return {
        ...meta,
        ...c,
        description: desc,
        ...(meta.temple_id ? { temple_id: meta.temple_id } : {}),
        ...(meta.title_hi ? { title_hi: meta.title_hi } : {}),
        ...(meta.temple_name_hi ? { temple_name_hi: meta.temple_name_hi } : {}),
        ...(meta.description_hi ? { description_hi: meta.description_hi } : {}),
        ...(meta.items_included ? { items_included: meta.items_included } : {}),
        ...(meta.items_included_hi ? { items_included_hi: meta.items_included_hi } : {}),
        ...(meta.significance ? { significance: meta.significance } : {}),
        ...(meta.significance_hi ? { significance_hi: meta.significance_hi } : {}),
        ...(meta.benefits ? { benefits: meta.benefits } : {}),
        ...(meta.benefits_hi ? { benefits_hi: meta.benefits_hi } : {}),
        ...(meta.faqs ? { faqs: meta.faqs } : {}),
      };
    } catch (_) {}
  }
  return c;
}

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('chadhawa_offerings')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    const enriched = (data || []).map(extractChadhawaMetadata);
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
      temple_id,
      temple_name,
      temple_name_hi,
      category,
      price,
      description,
      description_hi,
      image_url,
      items_included,
      items_included_hi,
      significance,
      significance_hi,
      benefits,
      benefits_hi,
      faqs,
    } = body;

    if (!title?.trim()) return NextResponse.json({ error: 'Offering title is required' }, { status: 400 });
    if (!temple_name?.trim()) return NextResponse.json({ error: 'Temple destination is required' }, { status: 400 });
    if (!category?.trim()) return NextResponse.json({ error: 'Category is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid price (₹) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `chadhawa_${Date.now()}`;

    const metadata = {
      temple_id: temple_id?.trim() || undefined,
      title_hi: title_hi?.trim() || undefined,
      temple_name_hi: temple_name_hi?.trim() || undefined,
      description_hi: description_hi?.trim() || undefined,
      items_included: items_included?.trim() || undefined,
      items_included_hi: items_included_hi?.trim() || undefined,
      significance: significance?.trim() || undefined,
      significance_hi: significance_hi?.trim() || undefined,
      benefits: benefits?.trim() || undefined,
      benefits_hi: benefits_hi?.trim() || undefined,
      faqs: Array.isArray(faqs) ? faqs : [],
    };

    const cleanDesc = (description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
    const finalDescription = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
      ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
      : cleanDesc;

    const basePayload: any = {
      id,
      title: title.trim(),
      temple_name: temple_name.trim(),
      category: category.trim(),
      price: Number(price),
      description: finalDescription,
      image_url: image_url.trim(),
    };
    if (temple_id) basePayload.temple_id = temple_id.trim();

    const fullPayload: any = {
      ...basePayload,
      ...(title_hi ? { title_hi: title_hi.trim() } : {}),
      ...(temple_name_hi ? { temple_name_hi: temple_name_hi.trim() } : {}),
      ...(description_hi ? { description_hi: description_hi.trim() } : {}),
      ...(items_included ? { items_included: items_included.trim() } : {}),
      ...(items_included_hi ? { items_included_hi: items_included_hi.trim() } : {}),
      ...(significance ? { significance: significance.trim() } : {}),
      ...(significance_hi ? { significance_hi: significance_hi.trim() } : {}),
      ...(benefits ? { benefits: benefits.trim() } : {}),
      ...(benefits_hi ? { benefits_hi: benefits_hi.trim() } : {}),
      ...(Array.isArray(faqs) ? { faqs } : {}),
    };
      ...(benefits ? { benefits: benefits.trim() } : {}),
      ...(benefits_hi ? { benefits_hi: benefits_hi.trim() } : {}),
      ...(Array.isArray(faqs) ? { faqs } : {}),
    };

    let result = await supabaseServer.from('chadhawa_offerings').upsert(fullPayload).select().single();

    if (result.error) {
      result = await supabaseServer.from('chadhawa_offerings').upsert(basePayload).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractChadhawaMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create offering' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Offering ID is required' }, { status: 400 });

    if (updates.price !== undefined) updates.price = Number(updates.price);

    const metadata = {
      temple_id: updates.temple_id?.trim() || undefined,
      title_hi: updates.title_hi?.trim() || undefined,
      temple_name_hi: updates.temple_name_hi?.trim() || undefined,
      description_hi: updates.description_hi?.trim() || undefined,
      items_included: updates.items_included?.trim() || undefined,
      items_included_hi: updates.items_included_hi?.trim() || undefined,
      significance: updates.significance?.trim() || undefined,
      significance_hi: updates.significance_hi?.trim() || undefined,
      benefits: updates.benefits?.trim() || undefined,
      benefits_hi: updates.benefits_hi?.trim() || undefined,
      faqs: Array.isArray(updates.faqs) ? updates.faqs : [],
    };

    if (updates.description !== undefined) {
      const cleanDesc = (updates.description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
      updates.description = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
        ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
        : cleanDesc;
    }

    let result = await supabaseServer.from('chadhawa_offerings').update(updates).eq('id', id).select().single();

    if (result.error) {
      const {
        title_hi,
        temple_name_hi,
        description_hi,
        items_included,
        items_included_hi,
        significance,
        significance_hi,
        benefits,
        benefits_hi,
        faqs,
        ...baseUpdates
      } = updates;
      result = await supabaseServer.from('chadhawa_offerings').update(baseUpdates).eq('id', id).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractChadhawaMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update offering' }, { status: 500 });
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
    return NextResponse.json({ error: err.message || 'Failed to delete offering' }, { status: 500 });
  }
}
