import { Account } from "starknet";
// @ts-ignore
import { ClientComponents } from "./createClientComponents";
import {
  getEvents,
  setComponentsFromEvents,
  getEntityIdFromKeys,
} from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";
import type { BigNumberish } from "starknet";
import { uuid } from "@latticexyz/utils";
import { PlantType } from "@/types";
import { useGardenStore } from "@/stores/gardenStore";
import { getComponentValue } from "@dojoengine/recs";
import { GardenCellType } from "@/types";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  { GardenCell }: ClientComponents
) {
  const initializeGarden = async (account: Account) => {
    try {
      const { transaction_hash } = await client.actions.initializeGarden({
        account,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
    }
  };

  const refreshGarden = async (account: Account) => {
    try {
      const { transaction_hash } = await client.actions.refreshGarden({
        account,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
    }
  };

  const removeRock = async (account: Account, cellIndex: number) => {
    // NOTE: we are creating a hash from the account address and the cell index
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

    try {
      const { transaction_hash } = await client.actions.removeRock({
        account,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );

      return { transactionHash: transaction_hash };
    } catch (e) {
      console.error(e);
    }
  };

  const removeDeadPlant = async (account: Account, cellIndex: number) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

    const gardenId = uuid();
    GardenCell.addOverride(gardenId, {
      entity: entityId,
      value: {
        player_address: BigInt(account.address),
        plant: {
          plant_type: 0, // NOTE: what is dead plant state?
          water_level: 0,
          growth_stage: 0,
          planted_at: 0,
          last_watered: 0,
        },
      },
    });

    try {
      const { transaction_hash } = await client.actions.removeDeadPlant({
        account,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
      GardenCell.removeOverride(gardenId);
    } finally {
      setTimeout(() => {
        GardenCell.removeOverride(gardenId);
      }, 1000);
    }
  };

  const waterPlant = async (account: Account, cellIndex: number) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

    const gardenId = uuid();
    GardenCell.addOverride(gardenId, {
      entity: entityId,
      value: {
        player_address: BigInt(account.address),
        plant: {
          plant_type: 0,
          water_level: 100,
          growth_stage: 0,
          planted_at: 0,
          last_watered: 0, // TODO: set to "now" here?
        },
      },
    });
    try {
      const { transaction_hash } = await client.actions.waterPlant({
        account,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
      GardenCell.removeOverride(gardenId);
    } finally {
      setTimeout(() => {
        GardenCell.removeOverride(gardenId);
      }, 1000);
    }
  };

  const plantSeed = async (
    account: Account,
    seedLow: number,
    seedHigh: number,
    cellIndex: number
  ) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
      BigInt(seedLow),
      BigInt(seedHigh),
    ]);

    // TODO: need to add is is_harvested
    const gardenId = uuid();
    GardenCell.addOverride(gardenId, {
      entity: entityId,
      value: {
        player_address: BigInt(account.address),
        plant: {
          plant_type: seedLow,
          water_level: 100,
          growth_stage: 0,
          planted_at: 0,
          last_watered: 0,
        },
      },
    });

    try {
      const { transaction_hash } = await client.actions.plantSeed({
        account,
        seedLow,
        seedHigh,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
      GardenCell.removeOverride(gardenId);
    } finally {
      setTimeout(() => {
        GardenCell.removeOverride(gardenId);
      }, 1000);
    }
  };

  const harvestPlant = async (account: Account, cellIndex: number) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

    const gardenId = uuid();
    GardenCell.addOverride(gardenId, {
      entity: entityId,
      value: {
        player_address: BigInt(account.address),
        plant: {
          plant_type: 0,
          water_level: 0,
          growth_stage: 0,
          planted_at: 0,
          last_watered: 0,
        },
      },
    });

    try {
      const { transaction_hash } = await client.actions.harvestPlant({
        account,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(e);
      GardenCell.removeOverride(gardenId);
    } finally {
      setTimeout(() => {
        GardenCell.removeOverride(gardenId);
      }, 1000);
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
