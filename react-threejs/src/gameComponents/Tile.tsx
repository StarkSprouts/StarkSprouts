import React from "react";
import { useThree } from "@react-three/fiber";
import { useAssets } from "@/gameComponents/AssetLoader";
import { PlaneGeometry, MeshBasicMaterial, Mesh } from "three";
import { getGardenPositionByCell } from "@/utils/gridHelper";

type TileProps = {
  type: TileType;
  position: [number, number];
};

export type AssetsType = {
  grass1: any;
  grass2: any;
  grass3: any;
  grass4: any;
  plot: any;
  topLeftCorner: any;
  topRightCorner: any;
  bottomRightCorner: any;
  bottomLeftCorner: any;
  leftEdge: any;
  rightEdge: any;
  topEdge: any;
  bottomEdge: any;
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
  const { scene } = useThree();
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
  if (!texture) return null;
  if (getGardenPositionByCell(244).toString() === position.toString()) {
    console.log("position", position);
    texture = grass1;
  }
  // Create a plane geometry for the tile
  const geometry = new PlaneGeometry(1, 1);
  const material = new MeshBasicMaterial({ map: texture });
  const mesh = new Mesh(geometry, material);

  // Set the position of the tile
  mesh.position.set(...position, 0);

  // Use the scene from useThree() to add the mesh
  scene.add(mesh);

  return null;
};
