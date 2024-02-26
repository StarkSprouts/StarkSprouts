import React, { createContext, useContext } from "react";
import { TextureLoader } from "three";
import { useLoader } from "@react-three/fiber";
//import { tileTextures } from "@/utils/textures";

const AssetsContext = createContext({});

type AssetLoaderProps = {
  children: React.ReactNode;
};

const texturePaths = {
  grass: "src/textures/tiles/grass/grass_15.png",
  plot: "src/textures/tiles/sand/sand_07.png",
  topLeftCorner: "src/textures/tiles/sand/sand_00.png",
  topRightCorner: "src/textures/tiles/sand/sand_02.png",
  bottomRightCorner: "src/textures/tiles/sand/sand_14.png",
  bottomLeftCorner: "src/textures/tiles/sand/sand_12.png",
  leftEdge: "src/textures/tiles/sand/sand_06.png",
  rightEdge: "src/textures/tiles/sand/sand_08.png",
  topEdge: "src/textures/tiles/sand/sand_01.png",
  bottomEdge: "src/textures/tiles/sand/sand_13.png",
};

export const AssetLoader = ({ children }: AssetLoaderProps) => {
  const textures = useLoader(TextureLoader, [
    texturePaths.grass,
    texturePaths.plot,
    texturePaths.topLeftCorner,
    texturePaths.topRightCorner,
    texturePaths.bottomRightCorner,
    texturePaths.bottomLeftCorner,
    texturePaths.leftEdge,
    texturePaths.rightEdge,
    texturePaths.topEdge,
    texturePaths.bottomEdge,
  ]);

  const assets = {
    grass: textures[0],
    plot: textures[1],
    topLeftCorner: textures[2],
    topRightCorner: textures[3],
    bottomRightCorner: textures[4],
    bottomLeftCorner: textures[5],
    leftEdge: textures[6],
    rightEdge: textures[7],
    topEdge: textures[8],
    bottomEdge: textures[9],
  };

  return (
    <AssetsContext.Provider value={assets}>{children}</AssetsContext.Provider>
  );
};

export const useAssets = () => useContext(AssetsContext);
