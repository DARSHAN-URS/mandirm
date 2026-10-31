import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

function extractProductMetadata(prod: any) {
  if (!prod || !prod.description) return prod;
  let desc = prod.description || '';
  const match = desc.match(/<!--\s*METADATA:\s*([\s\S]*?)\s*-->/);
  if (match && match[1]) {
    try {
      const meta = JSON.parse(match[1]);
      desc = desc.replace(match[0], '').trim();
      return {
        ...meta,
        ...prod,
        description: desc,
        ...(meta.name_hi ? { name_hi: meta.name_hi } : {}),
        ...(meta.description_hi ? { description_hi: meta.description_hi } : {}),
        ...(meta.material_hi ? { material_hi: meta.material_hi } : {}),
        ...(meta.benefits ? { benefits: meta.benefits } : {}),
        ...(meta.benefits_hi ? { benefits_hi: meta.benefits_hi } : {}),
        ...(meta.how_to_use ? { how_to_use: meta.how_to_use } : {}),
        ...(meta.how_to_use_hi ? { how_to_use_hi: meta.how_to_use_hi } : {}),
        ...(meta.package_contents ? { package_contents: meta.package_contents } : {}),
        ...(meta.package_contents_hi ? { package_contents_hi: meta.package_contents_hi } : {}),
        ...(meta.faqs ? { faqs: meta.faqs } : {}),
      };
    } catch (_) {}
  }
  return prod;
}

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('products')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    const enriched = (data || []).map(extractProductMetadata);
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
      category,
      price,
      original_price,
      description,
      description_hi,
      image_url,
      stock,
      material,
      material_hi,
      dimensions,
      is_featured,
      benefits,
      benefits_hi,
      how_to_use,
      how_to_use_hi,
      package_contents,
      package_contents_hi,
      faqs,
    } = body;

    if (!name?.trim()) return NextResponse.json({ error: 'Product name is required' }, { status: 400 });
    if (!category?.trim()) return NextResponse.json({ error: 'Category is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid selling price (₹) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `prod_${Date.now()}`;

    // Prepare embedded metadata for 100% column-independent persistence
    const metadata = {
      name_hi: name_hi?.trim() || undefined,
      description_hi: description_hi?.trim() || undefined,
      material_hi: material_hi?.trim() || undefined,
      benefits: benefits?.trim() || undefined,
      benefits_hi: benefits_hi?.trim() || undefined,
      how_to_use: how_to_use?.trim() || undefined,
      how_to_use_hi: how_to_use_hi?.trim() || undefined,
      package_contents: package_contents?.trim() || undefined,
      package_contents_hi: package_contents_hi?.trim() || undefined,
      faqs: Array.isArray(faqs) ? faqs : [],
    };

    const cleanDesc = (description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
    const finalDescription = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
      ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
      : cleanDesc;

    const basePayload = {
      id,
      name: name.trim(),
      category: category.trim(),
      price: Number(price),
      original_price: original_price ? Number(original_price) : Number(price) * 1.3,
      description: finalDescription,
      image_url: image_url.trim(),
      stock: stock !== undefined && !isNaN(Number(stock)) ? Number(stock) : 50,
      material: material?.trim() || 'Sacred Natural Material',
      dimensions: dimensions?.trim() || 'Standard Sanctum Size',
      rating: 4.9,
      reviews_count: 50,
      is_featured: is_featured ?? false,
    };

    // Try with extended native columns first
    const fullPayload = {
      ...basePayload,
      ...(name_hi ? { name_hi: name_hi.trim() } : {}),
      ...(description_hi ? { description_hi: description_hi.trim() } : {}),
      ...(material_hi ? { material_hi: material_hi.trim() } : {}),
      ...(benefits ? { benefits: benefits.trim() } : {}),
      ...(benefits_hi ? { benefits_hi: benefits_hi.trim() } : {}),
      ...(how_to_use ? { how_to_use: how_to_use.trim() } : {}),
      ...(how_to_use_hi ? { how_to_use_hi: how_to_use_hi.trim() } : {}),
      ...(package_contents ? { package_contents: package_contents.trim() } : {}),
      ...(package_contents_hi ? { package_contents_hi: package_contents_hi.trim() } : {}),
      ...(Array.isArray(faqs) ? { faqs } : {}),
    };

    let result = await supabaseServer.from('products').upsert(fullPayload).select().single();

    if (result.error) {
      // Fallback to base payload with embedded metadata
      result = await supabaseServer.from('products').upsert(basePayload).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractProductMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to create product' }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { id, ...updates } = body;

    if (!id) return NextResponse.json({ error: 'Product ID is required' }, { status: 400 });

    if (updates.price !== undefined) updates.price = Number(updates.price);
    if (updates.original_price !== undefined) updates.original_price = Number(updates.original_price);
    if (updates.stock !== undefined) updates.stock = Number(updates.stock);

    const metadata = {
      name_hi: updates.name_hi?.trim() || undefined,
      description_hi: updates.description_hi?.trim() || undefined,
      material_hi: updates.material_hi?.trim() || undefined,
      benefits: updates.benefits?.trim() || undefined,
      benefits_hi: updates.benefits_hi?.trim() || undefined,
      how_to_use: updates.how_to_use?.trim() || undefined,
      how_to_use_hi: updates.how_to_use_hi?.trim() || undefined,
      package_contents: updates.package_contents?.trim() || undefined,
      package_contents_hi: updates.package_contents_hi?.trim() || undefined,
      faqs: Array.isArray(updates.faqs) ? updates.faqs : [],
    };

    if (updates.description !== undefined) {
      const cleanDesc = (updates.description || '').replace(/<!--\s*METADATA:[\s\S]*?-->/g, '').trim();
      updates.description = Object.values(metadata).some(v => v !== undefined && (!Array.isArray(v) || v.length > 0))
        ? `${cleanDesc}\n\n<!-- METADATA: ${JSON.stringify(metadata)} -->`
        : cleanDesc;
    }

    let result = await supabaseServer.from('products').update(updates).eq('id', id).select().single();

    if (result.error) {
      // Clean non-standard columns for safe fallback
      const {
        name_hi,
        description_hi,
        material_hi,
        benefits,
        benefits_hi,
        how_to_use,
        how_to_use_hi,
        package_contents,
        package_contents_hi,
        faqs,
        ...baseUpdates
      } = updates;
      result = await supabaseServer.from('products').update(baseUpdates).eq('id', id).select().single();
      if (result.error) {
        return NextResponse.json({ error: result.error.message }, { status: 400 });
      }
    }

    return NextResponse.json({ success: true, data: extractProductMetadata(result.data) });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to update product' }, { status: 500 });
  }
}

export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const id = searchParams.get('id');

    if (!id) return NextResponse.json({ error: 'Product ID is required' }, { status: 400 });

    const { error } = await supabaseServer.from('products').delete().eq('id', id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Product deleted successfully' });
  } catch (err: any) {
    return NextResponse.json({ error: err.message || 'Failed to delete product' }, { status: 500 });
  }
}
