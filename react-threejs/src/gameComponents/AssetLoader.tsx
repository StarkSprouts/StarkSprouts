import React, { createContext, useContext } from "react";
import { TextureLoader } from "three";
import { useLoader } from "@react-three/fiber";
//import { tileTextures } from "@/utils/textures";

const AssetsContext = createContext({});

type AssetLoaderProps = {
  children: React.ReactNode;
};

export type AssetsType = {
  grass: any;
  plot: any;
};

export const AssetLoader = ({ children }: AssetLoaderProps) => {
  const textures = useLoader(TextureLoader, [
    "src/textures/tiles/Grass/grass_15.png",
    "src/textures/tiles/Sand/sand_09.png",
  ]);

  const assets = {
    grass: textures[0],
    plot: textures[1],
  };

  return (
    <AssetsContext.Provider value={assets as AssetsType}>
      {children}
    </AssetsContext.Provider>
  );
};

export const useAssets = () => useContext(AssetsContext);
