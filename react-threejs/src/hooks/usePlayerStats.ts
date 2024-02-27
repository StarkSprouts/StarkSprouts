import { useEffect, useState } from "react";
import { useDojo } from "@/dojo/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { getComponentValue } from "@dojoengine/recs";
import type { PlayerStatsType } from "@/types";

export const usePlayerStats = () => {
  const {
    account: { account },
    setup: {
      clientComponents: { PlayerStats },
    },
  } = useDojo();
  const [playerStats, setPlayerStats] = useState<PlayerStatsType>();
  const [rockRemovalPending, setRockRemovalPending] = useState<
    [boolean, number]
  >([false, 0]);
  const [hasGarden, setHasGarden] = useState(false);

  useEffect(() => {
    if (!account.address) return;
    const getPlayerStats = async () => {
      console.log("getting player stats");
      const entityId = getEntityIdFromKeys([BigInt(account.address)]);
      const stats = getComponentValue(PlayerStats, entityId);
      if (stats) {
        // @ts-ignore
        setPlayerStats(stats);

        // @ts-ignore
        if (stats.rock_pending || stats.rock_pending === 1) {
          setRockRemovalPending([true, stats.rock_pending_cell_index]);
        } else {
          setRockRemovalPending([false, 0]);
        }

        // @ts-ignore
        if (stats.has_garden || stats.has_garden === 1) {
          setHasGarden(true);
        } else {
          setHasGarden(false);
        }
      }
      console.log("player stats", stats);
    };

    getPlayerStats();

    const interval = setInterval(() => {
      getPlayerStats();
    }, 3000);
  }, [account]);

  return { playerStats, rockRemovalPending, hasGarden };
};
