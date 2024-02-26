import { create } from "zustand";
import { PlantType } from "@/types";
import type { GardenCellType } from "@/types";

export type GardenStore = {
  gardenCells: GardenCellType[]; // garden cell objects indexed by cell index
  setGardenCells: (gardenCells: GardenCellType[]) => void;
};

export const useGardenStore = create<GardenStore>((set) => ({
  gardenCells: [],
  setGardenCells: (gardenCells) => set({ gardenCells }),
}));
