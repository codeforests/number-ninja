/// <reference path="../pb_data/types.d.ts" />
// FEAT-14 (SYN-06): POST /api/nn/children/{id}/reset clears a child's
// progress on the server (rounds, attempts, badges; screen time stays,
// TIM-05), bumps `reset_epoch` and stamps `reset_at`, in one transaction.
// Other devices clear their copies older than `reset_at` at their next sync.
routerAdd("POST", "/api/nn/children/{id}/reset", (e) => {
  const id = e.request.pathValue("id");
  let child;
  try {
    child = e.app.findRecordById("children", id);
  } catch (_) {
    throw new NotFoundError("Child not found.");
  }
  if (child.getString("owner") !== e.auth.id) {
    throw new ForbiddenError("Not your child.");
  }

  let epoch = 0;
  let resetAt = "";
  e.app.runInTransaction((tx) => {
    for (const table of ["attempts", "rounds", "badges"]) {
      tx.db()
        .newQuery("DELETE FROM " + table + " WHERE child = {:child}")
        .bind({ child: id })
        .execute();
    }
    const c = tx.findRecordById("children", id);
    epoch = c.getInt("reset_epoch") + 1;
    c.set("reset_epoch", epoch);
    c.set("reset_at", new DateTime());
    tx.save(c);
    resetAt = c.getString("reset_at");
  });

  return e.json(200, { reset_epoch: epoch, reset_at: resetAt });
}, $apis.requireAuth("users"));
