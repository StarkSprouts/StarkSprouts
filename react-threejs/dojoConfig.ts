import manifest from "./manifest.json";
import { createDojoConfig } from "@dojoengine/core";

const toriiUrl = import.meta.env.VITE_TORII_URL;
const katanaUrl = import.meta.env.VITE_KATANA_URL;
const env = import.meta.env.VITE_ENV;

export const dojoConfig = createDojoConfig({
  manifest,
  toriiUrl: env === "production" ? toriiUrl : "http://localhost:8080",
  rpcUrl: env === "production" ? katanaUrl : "http://localhost:5050",
});
