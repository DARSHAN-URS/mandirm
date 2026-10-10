'use client';

import { useState } from 'react';

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  original_price: number;
  stock: number;
  material: string;
  is_featured: boolean;
}

const SEED_PRODUCTS: Product[] = [
  { id: 'PRD-01', name: 'Consecrated Brass Ganesha Murti (6-inch)', category: 'Idols & Murtis', price: 1250, original_price: 1800, stock: 45, material: 'Ashtadhatu Brass', is_featured: true },
  { id: 'PRD-02', name: 'Original 5-Mukhi Indonesian Rudraksha Mala (108 Beads)', category: 'Malas & Rosaries', price: 850, original_price: 1200, stock: 120, material: 'Natural Certified Rudraksha', is_featured: true },
  { id: 'PRD-03', name: 'Pure Parad (Mercury) Shivlinga with Jaladhari', category: 'Idols & Murtis', price: 2100, original_price: 2900, stock: 18, material: 'Purified Parad', is_featured: true },
  { id: 'PRD-04', name: 'Sandalwood & Guggal Natural Dhoop Cones (Box of 50)', category: 'Dhoop & Fragrance', price: 350, original_price: 450, stock: 250, material: 'Organic Herbs & Sandalwood', is_featured: false },
  { id: 'PRD-05', name: 'Navgrah Yantra (Gold Plated Sacred Copper Plate)', category: 'Yantras', price: 650, original_price: 950, stock: 65, material: '24K Gold Plated Copper', is_featured: true },
  { id: 'PRD-06', name: 'Kashi Gangajal Sanctified Holy Water (500ml Flask)', category: 'Puja Samagri', price: 250, original_price: 350, stock: 300, material: 'Direct from Manikarnika Ghat', is_featured: false },
];

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>(SEED_PRODUCTS);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');

  const categories = ['all', 'Idols & Murtis', 'Malas & Rosaries', 'Dhoop & Fragrance', 'Yantras', 'Puja Samagri'];

  const filtered = products.filter(p => {
    const matchSearch = p.name.toLowerCase().includes(search.toLowerCase());
    const matchCat = categoryFilter === 'all' || p.category === categoryFilter;
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🛍️</span> Spiritual Store & Prasad Products Catalog
          </h1>
          <p className="text-xs text-gray-500">
            Manage sacred idols, energized yantras, authentic Rudraksha malas, and organic puja samagri
          </p>
        </div>
        <button
          onClick={() => alert('New product creation form')}
          className="px-4 py-2 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
        >
          <span>+</span> Add New Product
        </button>
      </div>

      {/* Filter Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-3 shadow-sm">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="relative w-full sm:w-80">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search products by title..."
              className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
            />
          </div>
          <span className="text-xs text-gray-500 font-medium">Total Items: <strong>{products.length}</strong></span>
        </div>

        <div className="flex flex-wrap gap-2 pt-1 border-t border-gray-100">
          {categories.map(c => (
            <button
              key={c}
              onClick={() => setCategoryFilter(c)}
              className={`px-3 py-1 rounded-full text-xs font-semibold transition-all ${
                categoryFilter === c ? 'bg-mandir-maroon text-white shadow-sm' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {c === 'all' ? 'All Items' : c}
            </button>
          ))}
        </div>
      </div>

      {/* Products Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.map(p => (
          <div key={p.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 hover:shadow-md transition-all flex flex-col justify-between">
            <div>
              <div className="flex items-start justify-between mb-2">
                <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 uppercase">
                  {p.category}
                </span>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                  p.stock < 20 ? 'bg-red-100 text-red-800' : 'bg-emerald-100 text-emerald-800'
                }`}>
                  {p.stock} in stock
                </span>
              </div>
              <h3 className="font-bold text-sm text-gray-900 font-cinzel">{p.name}</h3>
              <p className="text-[11px] text-gray-500 mt-1">Material: {p.material}</p>
            </div>

            <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between">
              <div>
                <span className="text-base font-bold text-gray-900 font-mono">₹ {p.price}</span>
                <span className="text-xs text-gray-400 line-through ml-2 font-mono">₹ {p.original_price}</span>
              </div>
              <button
                onClick={() => alert(`Editing ${p.name}`)}
                className="px-3 py-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-lg text-xs"
              >
                Edit Stock
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
