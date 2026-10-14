import { NextResponse } from 'next/server';
import { supabaseServer } from '@/lib/supabase/server';

export async function GET() {
  try {
    const { data, error } = await supabaseServer
      .from('products')
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
    const { name, category, price, original_price, description, image_url, stock, material, dimensions, is_featured } = body;

    // Strict validation of required fields
    if (!name?.trim()) return NextResponse.json({ error: 'Product name is required' }, { status: 400 });
    if (!category?.trim()) return NextResponse.json({ error: 'Category is required' }, { status: 400 });
    if (price === undefined || price === null || isNaN(Number(price)) || Number(price) <= 0) {
      return NextResponse.json({ error: 'Valid selling price (₹) is required' }, { status: 400 });
    }
    if (!description?.trim()) return NextResponse.json({ error: 'Description is required' }, { status: 400 });
    if (!image_url?.trim()) return NextResponse.json({ error: 'Image URL is required' }, { status: 400 });

    const id = body.id || `prod_${Date.now()}`;

    const newProduct = {
      id,
      name: name.trim(),
      category: category.trim(),
      price: Number(price),
      original_price: original_price ? Number(original_price) : Number(price) * 1.3,
      description: description.trim(),
      image_url: image_url.trim(),
      stock: stock !== undefined && !isNaN(Number(stock)) ? Number(stock) : 50,
      material: material?.trim() || 'Sacred Natural Material',
      dimensions: dimensions?.trim() || 'Standard Sanctum Size',
      rating: 4.9,
      reviews_count: 50,
      is_featured: is_featured ?? false,
    };

    const { data, error } = await supabaseServer
      .from('products')
      .upsert(newProduct)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message, detail: error }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
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

    const { data, error } = await supabaseServer
      .from('products')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, data });
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
