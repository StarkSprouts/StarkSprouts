import React, { useRef, useEffect } from "react";
import { Canvas, useThree } from "@react-three/fiber";
import { Vector3 } from "three";
import { AssetLoader } from "@/gameComponents/AssetLoader";

type GameProps = {
  children: React.ReactNode;
};

export const Game = ({ children }: GameProps) => {
  return (
    <Canvas
      camera={{
        position: [0, 0, 30],
        zoom: 1,
        near: 0.1,
      }}
    >
      <AssetLoader>{children}</AssetLoader>
    </Canvas>
  );
};
