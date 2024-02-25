"use client";
import { setup } from "@/dojo/generated/setup";
import { DojoProvider } from "@/dojo/DojoContext";
import { dojoConfig } from "../../dojoConfig";
import { useState, useEffect } from "react";

export const DojoSetup = ({ children }: { children: React.ReactNode }) => {
  const [setupResult, setSetupResult] = useState<any>(null);

  useEffect(() => {
    const setupDojo = async () => {
      const result = await setup(dojoConfig);
      setSetupResult(result);
    };

    setupDojo();
  }, []);
  return <DojoProvider value={setupResult}>{children}</DojoProvider>;
};
