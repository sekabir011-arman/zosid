import { fileURLToPath, URL } from "url";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import environment from "vite-plugin-environment";

// Safe runtime-only fallback (NO process mutation)
const ii_url =
  process.env.DFX_NETWORK === "local"
    ? "http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:8081/"
    : "https://identity.internetcomputer.org/";

export default defineConfig({
  logLevel: "error",

  build: {
    emptyOutDir: true,
    sourcemap: false,
    minify: "esbuild", // ✅ production safe
  },

  css: {
    postcss: "./postcss.config.js",
  },

  optimizeDeps: {
    esbuildOptions: {
      define: {
        global: "globalThis",
      },
    },
  },

  server: {
    proxy: {
      "/api": {
        target: "http://127.0.0.1:4943",
        changeOrigin: true,
      },
    },
  },

  plugins: [
    environment(["CANISTER_*"]),
    environment(["DFX_*"]),
    environment(["II_URL"]),
    environment(["STORAGE_GATEWAY_URL"]),

    react(),
  ],

  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),

      // ✅ safer for Vercel builds
      declarations: fileURLToPath(
        new URL("./declarations", import.meta.url)
      ),
    },

    dedupe: ["@dfinity/agent"],
  },
});
