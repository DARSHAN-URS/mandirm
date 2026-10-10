/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        mandir: {
          maroon: "#8B1E1E",
          "maroon-dark": "#641010",
          "maroon-deep": "#1E0703",
          gold: "#F59E0B",
          "gold-dark": "#D97706",
          "gold-light": "#FEF3C7",
          saffron: "#FF6F00",
          cream: "#FFFDF9",
          ivory: "#FFF9F2",
          card: "#FFFFFF",
          border: "#EFE6DC",
          "text-main": "#2D2522",
          "text-muted": "#6B5E59",
        },
      },
      fontFamily: {
        cinzel: ["Cinzel", "serif"],
        poppins: ["Poppins", "sans-serif"],
      },
      boxShadow: {
        divine: "0 4px 20px -2px rgba(139, 30, 30, 0.08)",
        gold: "0 4px 20px -2px rgba(245, 158, 11, 0.2)",
      },
    },
  },
  plugins: [],
};
