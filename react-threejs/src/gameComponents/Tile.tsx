import React from "react";
import { useThree, useFrame } from "@react-three/fiber";
import { useAssets } from "@/gameComponents/AssetLoader";
import { PlaneGeometry, MeshBasicMaterial, Mesh } from "three";
import { getGardenPositionByCell } from "@/utils/gridHelper";
import { Plant } from "@/gameComponents/Plant";
import type { AssetsType } from "@/gameComponents/AssetLoader";

type TileProps = {
  type: TileType;
  position: [number, number];
};

export enum TileType {
  Grass = "G",
  Plot = "P",
  TopLeftCorner = "1",
  TopRightCorner = "2",
  BottomLeftCorner = "3",
  BottomRightCorner = "4",
  LeftEdge = "L",
  RightEdge = "R",
  TopEdge = "T",
  BottomEdge = "B",
}

export const Tile = ({ type, position }: TileProps) => {
  const [color, setColor] = React.useState("white");

  const {
    grass1,
    grass2,
    grass3,
    grass4,
    plot,
    topLeftCorner,
    topRightCorner,
    bottomRightCorner,
    bottomLeftCorner,
    leftEdge,
    rightEdge,
    topEdge,
    bottomEdge,
  } = useAssets() as AssetsType;

  // Example: Add different objects based on the tile type
  let texture;
  switch (type as TileType) {
    case TileType.Grass:
      // randomly choose a grass texture
      const grassTextures = [grass1, grass2, grass3, grass4];
      texture = grassTextures[Math.floor(Math.random() * grassTextures.length)];
      break;
    case TileType.Plot:
      texture = plot;
      break;
    case TileType.TopLeftCorner:
      texture = topLeftCorner;
      break;
    case TileType.TopRightCorner:
      texture = topRightCorner;
      break;
    case TileType.BottomRightCorner:
      texture = bottomRightCorner;
      break;
    case TileType.BottomLeftCorner:
      texture = bottomLeftCorner;
      break;
    case TileType.LeftEdge:
      texture = leftEdge;
      break;
    case TileType.RightEdge:
      texture = rightEdge;
      break;
    case TileType.TopEdge:
      texture = topEdge;
      break;
    case TileType.BottomEdge:
      texture = bottomEdge;
      break;
  }

  return (
    <>
      <mesh position={[...position, 0]}>
        <planeGeometry args={[1, 1]} />
        <meshBasicMaterial attach="material" color={color} map={texture} />
      </mesh>
    </>
  );
};
