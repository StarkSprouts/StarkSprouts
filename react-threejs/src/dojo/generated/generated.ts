// NOTE: in the future this file should be generated, but right now it's manually created

import { Account, BigNumberish } from "starknet";
import { DojoProvider } from "@dojoengine/core";

export type IWorld = Awaited<ReturnType<typeof setupWorld>>;

export async function setupWorld(provider: DojoProvider) {
  function actions() {
    const contract_name = "actions";

    const initializeGarden = async ({ account }: { account: Account }) => {
      try {
        return await provider.execute(
          account,
          contract_name,
          "initialize_garden",
          []
        );
      } catch (error) {
        console.error("Error initializing garden:", error);
        throw error;
      }
    };

    const refreshGarden = async ({ account }: { account: Account }) => {
      try {
        return await provider.execute(
          account,
          contract_name,
          "refresh_garden",
          []
        );
      } catch (error) {
        console.error("Error updating garden:", error);
        throw error;
      }
    };

    const waterPlant = async ({
      account,
      cellIndex,
    }: {
      account: Account;
      cellIndex: number;
    }) => {
      try {
        return await provider.execute(account, contract_name, "water_plant", [
          cellIndex,
        ]);
      } catch (error) {
        console.error("Error watering plant:", error);
        throw error;
      }
    };

    const removeRock = async ({
      account,
      cellIndex,
    }: {
      account: Account;
      cellIndex: number;
    }) => {
      try {
        return await provider.execute(account, contract_name, "remove_rock", [
          cellIndex,
        ]);
      } catch (error) {
        console.error("Error removing rock:", error);
        throw error;
      }
    };

    const removeDeadPlant = async ({
      account,
      cellIndex,
    }: {
      account: Account;
      cellIndex: number;
    }) => {
      try {
        return await provider.execute(
          account,
          contract_name,
          "remove_dead_plant",
          [cellIndex]
        );
      } catch (error) {
        console.error("Error removing dead plant:", error);
        throw error;
      }
    };

    const plantSeed = async ({
      account,
      seedLow,
      seedHigh,
      cellIndex,
    }: {
      account: Account;
      seedLow: number;
      seedHigh: number;
      cellIndex: number;
    }) => {
      try {
        return await provider.execute(account, contract_name, "plant_seed", [
          seedLow,
          seedHigh,
          cellIndex,
        ]);
      } catch (error) {
        console.error("Error planting seeds:", error);
        throw error;
      }
    };

    const harvestPlant = async ({
      account,
      cellIndex,
    }: {
      account: Account;
      cellIndex: number;
    }) => {
      try {
        return await provider.execute(
          account,
          contract_name,
          "harvest_plants",
          [cellIndex]
        );
      } catch (error) {
        console.error("Error harvesting plants:", error);
        throw error;
      }
    };

    return {
      initializeGarden,
      refreshGarden,
      removeRock,
      removeDeadPlant,
      waterPlant,
      plantSeed,
      harvestPlant,
    };
  }
  return {
    actions: actions(),
  };
}
