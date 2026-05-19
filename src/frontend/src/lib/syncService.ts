import { nhost } from "./nhost";
import { backend } from "./icp";

export async function syncPatients() {
  const queue = await backend.getSyncQueue();

  for (const item of queue) {
    if (item.entityType === "patient" && item.action === "create") {
      await nhost.graphql.request(`
        mutation {
          insert_patients_one(object: {
            id: "${item.entityId}",
            full_name: "Synced Patient"
          }) {
            id
          }
        }
      `);
    }
  }
}
