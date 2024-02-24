"use client";
import GardenCell from "./GardenCell";

export default function GardenContainer() {
  return (
    <main className="flex ">
      <div className="grid grid-cols-15 gap-1">
        {Array(15)
          .fill(0)
          .map((_, row) => (
            <div key={row} className="flex justify-evenly">
              {Array(15)
                .fill(0)
                .map((_, col) => (
                  <GardenCell
                    key={row * 15 + col}
                    cellNumber={row * 15 + col}
                  />
                ))}
            </div>
          ))}
      </div>
    </main>
  );
}
