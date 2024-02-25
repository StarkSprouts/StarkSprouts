import React from "react";
import { useThree } from "@react-three/fiber";
import { useAssets } from "@/gameComponents/AssetLoader";
import type { AssetsType } from "@/gameComponents/AssetLoader";
import { PlaneGeometry, MeshBasicMaterial, Mesh } from "three";

type TileProps = {
  type: string;
  position: [number, number];
};

type TileType = "G" | "P";

export const Tile = ({ type, position }: TileProps) => {
  const { scene } = useThree();
  const { grass, plot } = useAssets() as AssetsType;

  // Example: Add different objects based on the tile type
  let texture;
  switch (type) {
    case "G":
      // Add grass tile
      texture = grass;
      break;
    case "P":
      // Add soil plot
      texture = plot;
      break;
    default:
      // Default tile if needed
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
