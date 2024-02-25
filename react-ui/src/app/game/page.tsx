"use client";
import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";

const GamePage: React.FC = () => {
  return (
    <div className="flex justify-center items-center w-screen h-screen">
      <Game>
        <WorldScene />
      </Game>
    </div>
  );
};

export default GamePage;
