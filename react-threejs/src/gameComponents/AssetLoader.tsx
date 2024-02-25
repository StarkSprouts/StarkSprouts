import React, { createContext, useContext } from "react";
import { TextureLoader } from "three";
import { useLoader } from "@react-three/fiber";
import { tileTextures } from "@/utils/textures";

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
    tileTextures.grass[15],
    tileTextures.sand.center1,
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
