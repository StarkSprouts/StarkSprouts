import React from "react";
import { useThree } from "@react-three/fiber";
import { useAssets } from "@/gameComponents/AssetLoader";
import { PlaneGeometry, MeshBasicMaterial, Mesh } from "three";

type TileProps = {
  type: TileType;
  position: [number, number];
};

export type AssetsType = {
  grass: any;
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
    grass,
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
      console.log("Grass");
      texture = grass;
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
