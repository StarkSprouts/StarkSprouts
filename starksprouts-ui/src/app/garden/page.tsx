"use client";
import WalletButton from "@/components/WalletButton";
import GardenContainer from "@/components/garden-ui/GardenContainer";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";

export default function Garden() {
  const { address } = useAccount();

  return (
    <main className="flex flex-col  min-h-screen gap-12">
      <div className="flex flex-row w-screen justify-end p-2">
        <WalletButton />
      </div>

      {address ? <GardenView /> : <DisconnectedView />}
    </main>
  );
}

function GardenView() {
  return (
    <div className="w-screen flex justify-center items-center">
      <GardenContainer />
    </div>
  );
}

function DisconnectedView() {
  return (
    <div className="w-screen flex justify-center items-center">
      <p className="text-2xl font-bold">
        Connect your wallet to view your garden
      </p>
    </div>
  );
}
