"use client";
import { Canvas } from "@react-three/fiber";
import { useLoader } from "@react-three/fiber";
import { TextureLoader } from "three";
import { extend } from "@react-three/fiber";

export default function Garden() {
  return (
    <div>
      <Canvas>
        <GardenScene />
      </Canvas>
    </div>
  );
}

function GardenScene() {
  return (
    <>
      <ambientLight intensity={0.5} />
      <directionalLight position={[0, 10, 10]} intensity={1} />
      <GardenTiles />
      <Plants />
    </>
  );
}

function GardenTiles() {
  const texture = useLoader(TextureLoader, "/TileSet/Grass/Grass_01.png");

  return (
    <mesh position={[0, 0, 0]}>
      <planeGeometry attach="geometry" args={[1, 1]} />
      <meshBasicMaterial attach="material" map={texture} />
    </mesh>
  );
}

function Plants() {
  const plantTexture = useLoader(TextureLoader, "/plants/salvia/salvia_17.png");
  return (
    <mesh position={[1, 1, 0.1]}>
      <planeGeometry attach="geometry" args={[0.5, 0.5]} />
      <meshBasicMaterial attach="material" map={plantTexture} />
    </mesh>
  );
}
/*
import WalletButton from "@/components/WalletButton";
import GardenContainer from "@/components/garden/GardenContainer";
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
*/
