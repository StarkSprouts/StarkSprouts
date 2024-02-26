import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";
import useWindowSize from "@/hooks/useWindowSize";
import { Plant } from "@/gameComponents/Plant";

export default function GamePage() {
  const [width, height] = useWindowSize();
  return (
    <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
      <div className="absolute z-10 top-10 bg-slate-500 opacity-15"></div>
      <Game canvasWidth={width} canvasHeight={height}>
        <WorldScene />
      </Game>
    </div>
  );
}
