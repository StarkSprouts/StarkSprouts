"use client";
import WalletButton from "@/components/WalletButton";
import GardenContainer from "@/components/GardenContainer";

export default function Garden() {
  return (
    <main className="flex flex-col  min-h-screen gap-12">
      <div className="flex flex-row w-screen justify-end p-2">
        <WalletButton />
      </div>

      <div className="w-screen flex justify-center items-center">
        <GardenContainer />
      </div>
    </main>
  );
}
