import React, { createContext, useContext } from "react";
import { TextureLoader } from "three";
import { useLoader } from "@react-three/fiber";
//import { tileTextures } from "@/utils/textures";

const AssetsContext = createContext({});

type AssetLoaderProps = {
  children: React.ReactNode;
};

const texturePaths = {
  grass1: "src/textures/tiles/grass/grass_06.png",
  grass2: "src/textures/tiles/grass/grass_08.png",
  grass3: "src/textures/tiles/grass/grass_14.png",
  grass4: "src/textures/tiles/grass/grass_15.png",
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
    texturePaths.grass1,
    texturePaths.grass2,
    texturePaths.grass3,
    texturePaths.grass4,
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
    grass1: textures[0],
    grass2: textures[1],
    grass3: textures[2],
    grass4: textures[3],
    plot: textures[4],
    topLeftCorner: textures[5],
    topRightCorner: textures[6],
    bottomRightCorner: textures[7],
    bottomLeftCorner: textures[8],
    leftEdge: textures[9],
    rightEdge: textures[10],
    topEdge: textures[11],
    bottomEdge: textures[12],
  };

  return (
    <AssetsContext.Provider value={assets}>{children}</AssetsContext.Provider>
  );
};

export const useAssets = () => useContext(AssetsContext);
