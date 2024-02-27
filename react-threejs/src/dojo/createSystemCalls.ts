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
            retryInterval: 500,
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

  const waterPlant = async (account: Account, cellIndex: number) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

    const gardenId = uuid();
    try {
      const { transaction_hash } = await client.actions.waterPlant({
        account,
        cellIndex,
      });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 10,
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
    }
  };

  const harvestPlant = async (account: Account, cellIndex: number) => {
    const entityId = getEntityIdFromKeys([
      BigInt(account.address),
      BigInt(cellIndex),
    ]);

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
