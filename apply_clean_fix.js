const fs = require('fs');
const path = require('path');

const pagePath = path.join(__dirname, 'consumer_website', 'src', 'app', 'page.tsx');
let content = fs.readFileSync(pagePath, 'utf8');

// 1. Remove the broken live darshan button remnant
const brokenSnippetRegex = /<span className="absolute top-3 left-3 bg-mandir-maroon text-white text-\[11px\] font-bold px-2\.5 py-1 rounded-lg">\{temple\.deity\}<\/span>\r?\n\s*className="absolute bottom-3 right-3 bg-rose-600[\s\S]*?<\/button>\s*\r?\n\s*\)\}/g;

if (brokenSnippetRegex.test(content)) {
  content = content.replace(brokenSnippetRegex, '<span className="absolute top-3 left-3 bg-mandir-maroon text-white text-[11px] font-bold px-2.5 py-1 rounded-lg">{temple.deity}</span>');
  console.log('[+] Removed broken live darshan button snippet from page.tsx');
} else {
  // Line-by-line fallback
  const lines = content.split(/\r?\n/);
  const filtered = [];
  let skipping = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.includes('className="absolute bottom-3 right-3 bg-rose-600') && !line.includes('<button')) {
      skipping = true;
      continue;
    }
    if (skipping) {
      if (line.trim() === ')}' || line.includes('</button>')) {
        if (line.trim() === ')}') {
          skipping = false;
        }
        continue;
      }
    }
    filtered.push(line);
  }
  content = filtered.join('\r\n');
  console.log('[+] Cleaned line-by-line fallback');
}

// 2. Reorganize imports: all imports before dynamic components
const dynamicBlock = `const SankalpModal = dynamic(() => import("../components/modals/SankalpModal"), { ssr: false });
const CartDrawer = dynamic(() => import("../components/modals/CartDrawer"), { ssr: false });
const DevotionalDrawer = dynamic(() => import("../components/modals/DevotionalDrawer"), { ssr: false });
const AiJyotishModal = dynamic(() => import("../components/modals/AiJyotishModal"), { ssr: false });
const ConsultationModal = dynamic(() => import("../components/modals/ConsultationModal"), { ssr: false });
const DevotionalDashboard = dynamic(() => import("../components/home/DevotionalDashboard"), { ssr: false });`;

if (content.includes(dynamicBlock)) {
  content = content.replace(dynamicBlock, '');
  // Insert dynamicBlock right after the last import
  const lastImportIdx = content.lastIndexOf('} from "lucide-react";');
  if (lastImportIdx !== -1) {
    const insertPos = lastImportIdx + '} from "lucide-react";'.length;
    content = content.slice(0, insertPos) + '\r\n\r\n' + dynamicBlock + '\r\n' + content.slice(insertPos);
    console.log('[+] Reordered imports cleanly');
  }
}

// 3. Ensure live darshan modal is not present
content = content.replace(/\{\/\* Live Darshan Modal removed \*\/ false && \(\(\) => \{[\s\S]*?\}\)\(\)\}/g, '');
content = content.replace(/\/\* Live Darshan Modal removed \*\/ false && \(\(\) => \{[\s\S]*?\}\)\(\)/g, '');

fs.writeFileSync(pagePath, content, 'utf8');
console.log('[+] consumer_website/src/app/page.tsx updated successfully!');

