import { Account } from "starknet";
// @ts-ignore
import { ClientComponents } from "./createClientComponents";
import { getEvents, setComponentsFromEvents } from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  { GardenCell }: ClientComponents
) {
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

  const waterPlant = async (account: Account, cellIndex: number) => {
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
    }
  };

  const plantSeed = async (
    account: Account,
    cellIndex: number,
    seed: number
  ) => {
    try {
      const { transaction_hash } = await client.actions.plantSeed({
        account,
        seed,
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
    refreshGarden,
    removeRock,
    removeDeadPlant,
    waterPlant,
    plantSeed,
    harvestPlant,
  };
}
