import { Account } from "starknet";
// @ts-ignore
import { Entity, getComponentValue } from "@dojoengine/recs";
import { uuid } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import {
  getEntityIdFromKeys,
  getEvents,
  setComponentsFromEvents,
} from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  { GardenCell }: ClientComponents
) {
  const initializeGarden = async (account: Account) => {
    try {
      const { transaction_hash } = await client.actions.updateGarden({
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
    } catch (e) {
      console.error(e);
    }
  };

  const removeDeadPlant = async (account: Account, cellIndex: number) => {
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
    }
  };

  const waterPlants = async (account: Account, cellIndexes: number[]) => {
    try {
      const { transaction_hash } = await client.actions.waterPlants({
        account,
        cellIndexes,
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

  const plantSeeds = async (
    account: Account,
    cellIndexes: number[],
    seeds: number[]
  ) => {
    try {
      const { transaction_hash } = await client.actions.plantSeeds({
        account,
        seeds,
        cellIndexes,
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

  const harvestPlants = async (account: Account, cellIndexes: number[]) => {
    try {
      const { transaction_hash } = await client.actions.harvestPlants({
        account,
        cellIndexes,
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

  return {
    initializeGarden,
    removeRock,
    removeDeadPlant,
    waterPlants,
    plantSeeds,
    harvestPlants,
  };
}
