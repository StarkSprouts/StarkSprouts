"use client";
import { Button } from "@/components/Button";

export default function Home() {
  return (
    <main className="flex flex-col min-h-screen gap-12">
      <div className="flex flex-row w-screen justify-end p-2">
        <div>
          <Button>
            <a href="/garden">Launch App</a>
          </Button>
        </div>
      </div>

      <div className="flex flex-col justify-center items-center">
        <div className="p-4">
          <p className="text-2xl font-bold">StarkSprouts</p>
        </div>
        <img src="/logo.png" width={300} />
      </div>
    </main>
  );
}
